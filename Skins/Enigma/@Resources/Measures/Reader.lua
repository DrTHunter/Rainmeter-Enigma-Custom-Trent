function Initialize()
	-- SET UPDATE DIVIDER
	SKIN:Bang('!SetOption', SELF:GetName(), 'UpdateDivider', -1)
	-- This script never needs to update on a schedule. It should only
	-- update when it gets a "Refresh" command from WebParser.

	-- CREATE MAIN DATABASE
	Feeds = {}

	-- CREATE TYPE MATCHING PATTERNS AND FORMATTING FUNCTIONS
	DefineTypes()

	-- GET MEASURE NAMES
	local AllMeasureNames = SELF:GetOption('MeasureName', '')
	for MeasureName in AllMeasureNames:gmatch('[^%|]+') do
		table.insert(Feeds, {
			Measure     = SKIN:GetMeasure(MeasureName),
			MeasureName = MeasureName,
			Raw         = nil,
			Type        = nil,
			Title       = nil,
			Link        = nil,
			Error       = nil
			})
	end

	-- MODULES
	EventFile_Initialize()
	HistoryFile_Initialize()

	-- SET STARTING FEED
	f = f or 1

	-- SET USER INPUT
	UserInput = false
	-- Used to detect when an item has been marked as read.
end

function Update()
	Input()
	return Output()
end

-----------------------------------------------------------------------
-- INPUT

function Input(a)
	local f = a or f

	local Raw = Feeds[f].Measure:GetStringValue()

	if Raw == '' then
		Feeds[f].Error = {
			Description = 'Waiting for data from WebParser.',
			Title       = 'Loading...',
			Link        = 'http://enigma.kaelri.com/support'
			}
		return false
	elseif (Raw ~= Feeds[f].Raw) or UserInput then
		Feeds[f].Raw = Raw

		-- CONVERT ICALENDAR DATA
		-- Google retired the GData Atom feeds this reader was built for;
		-- modern calendar addresses serve iCalendar (.ics) data instead.
		if Raw:match('BEGIN:VCALENDAR') then
			Raw = ConvertICS(Raw)
		end

		-- DETERMINE FEED FORMAT AND CONTENTS
		local t = IdentifyType(Raw)

		if not t then
			Feeds[f].Error = {
				Description = 'Could not identify a valid feed format.',
				Title       = 'Invalid Feed Format',
				Link        = 'http://enigma.kaelri.com/support'
				}
			return false
		else
			Feeds[f].Type = t
		end

		-- MAKE SYNTAX PRETTIER
		local Type = Types[t]

		-- GET NEW DATA
		Feeds[f].Title = Raw:match('<title.->(.-)</title>') or 'Untitled'
		Feeds[f].Link  = Raw:match(Type.MatchLink)          or nil

		local Items = {}
		for RawItem in Raw:gmatch(Type.MatchItem) do
			local Item  = {}

			-- MATCH RAW DATA
			Item.Unread = 1
			Item.Title  = RawItem:match('<title.->(.-)</title>') or nil
			Item.Link   = RawItem:match(Type.MatchItemLink)      or nil
			Item.Desc   = RawItem:match(Type.MatchItemDesc)      or nil
			Item.Date   = RawItem:match(Type.MatchItemDate)      or nil
			Item.ID     = RawItem:match(Type.MatchItemID)        or Item.Link or Item.Title or Item.Desc or Item.Date

			-- ADDITIONAL PARSING
			if (not Item.Title) or (Item.Title == '') then
				Item.Title = 'Untitled'
			elseif SELF:GetNumberOption('StripTitleSource', 0) == 1 then
				-- Google News appends " - Publisher" to every headline.
				Item.Title = Item.Title:gsub('%s+%-%s+[^%-]+$', '')
			end
			if Item.Desc then
				Item.Desc = Item.Desc:gsub('<.->', '')
				Item.Desc = Item.Desc:gsub('%s%s+', ' ')
			end
			Item.Date, Item.AllDay, Item.RealDate = IdentifyDate(Item.Date, t)

			table.insert(Items, Item)
		end
		
		-- IDENTIFY DUPLICATES
		for i, OldItem in ipairs(Feeds[f]) do
			for j, NewItem in ipairs(Items) do
				if NewItem.ID == OldItem.ID then
					Feeds[f][i].Match = j
					Items[j].Unread   = OldItem.Unread
					if NewItem.RealDate == 0 then
						Items[j].Date   = OldItem.Date
						Items[j].AllDay = OldItem.AllDay
					end
				end
			end
		end

		-- CLEAR DUPLICATES OR ALL HISTORY
		local KeepOldItems = SELF:GetNumberOption('KeepOldItems', 0)

		if (KeepOldItems == 1) and Type.MergeItems then
			for i = #Feeds[f], 1, -1 do
				if Feeds[f][i].Match then
					table.remove(Feeds[f], i)
				end
			end
		else
			for i = 1, #Feeds[f] do
				table.remove(Feeds[f])
			end
		end

		-- ADD NEW ITEMS
		for i = #Items, 1, -1 do
			if Items[i] then
				table.insert(Feeds[f], 1, Items[i])
			end
		end

		-- CHECK NUMBER OF ITEMS
		local MaxItems = SELF:GetNumberOption('MaxItems', nil)
		local MaxItems = (MaxItems > 0) and MaxItems or nil

		if #Feeds[f] == 0 then
			Feeds[f].Error = {
				Description = 'No items found.',
				Title       = Feeds[f]['Title'],
				Link        = Feeds[f]['Link']
			}
			return false
		elseif MaxItems and (#Feeds[f] > MaxItems) then
			for i = #Feeds[f], (MaxItems + 1), -1 do
				table.remove(Feeds[f])
			end
		end
		
		-- MODULES
		EventFile_Update(f)
		HistoryFile_Update(f)

		-- CLEAR ERRORS FROM PREVIOUS UPDATE
		Feeds[f].Error = nil

		-- RESET USER INPUT
		UserInput = false
	end

	return true
end

-----------------------------------------------------------------------
-- OUTPUT

function Output()
	local Queue = {}

	-- MAKE SYNTAX PRETTIER
	local Feed  = Feeds[f]
	local Type  = Types[Feed.Type]
	local Error = Feed.Error

	-- CHECK FOR INPUT ERRORS
	local MinItems  = SELF:GetNumberOption('MinItems', 0)
	local Timestamp = SELF:GetOption('Timestamp', '%I.%M %p on %d %B %Y')

	-- CLAMP SCROLL OFFSET
	local Offset = math.min(Feed.Offset or 0, math.max(#Feed - math.max(MinItems, 1), 0))
	Feed.Offset = Offset

	-- BUILD QUEUE
	Queue['CurrentFeed']   = f
	Queue['NumberOfItems'] = #Feed
	Queue['ScrollOffset']  = Offset

	if Error then
		-- ERROR; QUEUE MESSAGES
		Queue['FeedTitle']   = Error.Title
		Queue['FeedLink']    = Error.Link
		Queue['Item1Title']  = Error.Description
		Queue['Item1Link']   = Error.Link
		Queue['Item1Desc']   = ''
		Queue['Item1Date']   = ''
		Queue['Item1Unread'] = 0
		Queue['Item1Number'] = 1

		for i = 2, MinItems do
			Queue['Item'..i..'Title']   = ''
			Queue['Item'..i..'Link']    = ''
			Queue['Item'..i..'Desc']    = ''
			Queue['Item'..i..'Date']    = ''
			Queue['Item'..i..'Unread']  = 0
			Queue['Item'..i..'Number']  = i
		end
	else
		-- NO ERROR; QUEUE FEED
		Queue['FeedTitle'] = Feed.Title
		Queue['FeedLink']  = Feed.Link or ''

		for i = 1, math.max(#Feed, MinItems) do
			local Item = Feed[i + Offset] or {}
			Queue['Item'..i..'Title']   = Item.Title  or ''
			Queue['Item'..i..'Link']    = Item.Link   or Feed.Link or ''
			Queue['Item'..i..'Desc']    = Item.Desc   or ''
			Queue['Item'..i..'Unread']  = Item.Unread or ''
			Queue['Item'..i..'Date']    = Item.Date and os.date(Timestamp, Item.Date) or ''
			-- Position within the whole feed, so numbered lists keep
			-- counting up as the user scrolls past the visible window.
			Queue['Item'..i..'Number']  = i + Offset
		end
	end

	-- SET VARIABLES
	local VariablePrefix = SELF:GetOption('VariablePrefix', '')
	for k, v in pairs(Queue) do
		SKIN:Bang('!SetVariable', VariablePrefix..k, v)
	end

	-- FINISH ACTION
	local FinishAction = SELF:GetOption('FinishAction', '')
	if FinishAction ~= '' then
		SKIN:Bang(FinishAction)
	end

	return Error and Error.Description or 'Finished #'..f..' ('..Feed.MeasureName..'). Name: '..Feed.Title..'. Type: '..Feed.Type..'. Items: '..#Feed..'.'
end

-----------------------------------------------------------------------
-- EXTERNAL COMMANDS

function Refresh(a)
	a = a and tonumber(a) or f
	if a == f then
		SKIN:Bang('!UpdateMeasure', SELF:GetName())
	else
		Input(a)
	end
end

function Show(a)
	f = tonumber(a)
	SKIN:Bang('!UpdateMeasure', SELF:GetName())
end

function ShowNext()
	f = (f % #Feeds) + 1
	SKIN:Bang('!UpdateMeasure', SELF:GetName())
end

function ShowPrevious()
	f = (f == 1) and #Feeds or (f - 1)
	SKIN:Bang('!UpdateMeasure', SELF:GetName())
end

function Scroll(a)
	local Visible = math.max(SELF:GetNumberOption('MinItems', 1), 1)
	local Max     = math.max(#Feeds[f] - Visible, 0)
	local o       = (Feeds[f].Offset or 0) + (tonumber(a) or 0)
	Feeds[f].Offset = math.max(0, math.min(o, Max))
	SKIN:Bang('!UpdateMeasure', SELF:GetName())
end

function MarkRead(a, b)
	b = b and tonumber(b) or f
	Feeds[b][a].Unread = 0
	UserInput = true
	SKIN:Bang('!UpdateMeasure', SELF:GetName())
end

function MarkUnread(a, b)
	b = b and tonumber(b) or f
	Feeds[b][a].Unread = 1
	UserInput = true
	SKIN:Bang('!UpdateMeasure', SELF:GetName())
end

function ToggleUnread(a, b)
	b = b and tonumber(b) or f
	Feeds[b][a].Unread = 1 - Feeds[b][a].Unread
	UserInput = true
	SKIN:Bang('!UpdateMeasure', SELF:GetName())
end

-----------------------------------------------------------------------
-- ICALENDAR CONVERSION
-- Converts iCalendar (.ics) data to the legacy gCal Atom format that
-- the parser above expects. Handles recurring events (RRULE), excluded
-- dates (EXDATE), and modified instances (RECURRENCE-ID).

function IcsUnescape(s)
	s = s:gsub('\\[nN]', ' ')
	s = s:gsub('\\(.)', '%1')
	return s
end

function IcsCleanText(s)
	s = s:gsub('[<>]', '')
	s = s:gsub('%s%s+', ' ')
	-- Strip mangled emoji: characters outside the system codepage arrive
	-- from WebParser as '?' runs at the edges of the text.
	s = s:gsub('^%?+%s*', '')
	s = s:gsub('%s+%?+$', '')
	return s
end

function IcsParseDate(Value)
	local D = {}
	D.year, D.month, D.day = Value:match('(%d%d%d%d)(%d%d)(%d%d)')
	if not D.year then return nil end
	D.hour, D.min, D.sec = Value:match('%d%d%d%d%d%d%d%dT(%d%d)(%d%d)(%d%d)')
	D.UTC    = (Value:match('Z') ~= nil)
	D.AllDay = (D.hour == nil)
	D.year   = tonumber(D.year)
	D.month  = tonumber(D.month)
	D.day    = tonumber(D.day)
	D.hour   = tonumber(D.hour)
	D.min    = tonumber(D.min)
	D.sec    = tonumber(D.sec)
	return D
end

function IcsTime(D)
	-- Approximate local timestamp, used for sorting and window filtering.
	local t = os.time{ year = D.year, month = D.month, day = D.day, hour = D.hour or 0, min = D.min or 0, sec = D.sec or 0 }
	if D.UTC then
		t = t + IcsUtcOffset
	end
	return t
end

function IcsDateKey(D)
	return string.format('%04d%02d%02d', D.year, D.month, D.day)
end

function IcsFormatDate(D)
	-- Formats a date table in the style of the old GData startTime attribute.
	if D.AllDay then
		return string.format('%04d-%02d-%02d', D.year, D.month, D.day)
	end
	local s = string.format('%04d-%02d-%02dT%02d:%02d:%02d.000', D.year, D.month, D.day, D.hour, D.min, D.sec)
	if D.UTC then
		s = s..'Z'
	end
	return s
end

function IcsShiftDays(D, n)
	local t = os.date('*t', os.time{ year = D.year, month = D.month, day = D.day + n, hour = 12 })
	return { year = t.year, month = t.month, day = t.day, hour = D.hour, min = D.min, sec = D.sec, UTC = D.UTC, AllDay = D.AllDay }
end

function IcsShiftMonths(D, n)
	local t = os.date('*t', os.time{ year = D.year, month = D.month + n, day = 1, hour = 12 })
	-- Skip months where the target day does not exist (e.g. Feb 30).
	local Check = os.date('*t', os.time{ year = t.year, month = t.month, day = D.day, hour = 12 })
	if Check.month ~= t.month then return nil end
	return { year = t.year, month = t.month, day = D.day, hour = D.hour, min = D.min, sec = D.sec, UTC = D.UTC, AllDay = D.AllDay }
end

function IcsExpand(Start, RRule, Excluded, WindowStart, WindowEnd)
	-- Expands a recurrence rule into a list of occurrence date tables.
	local R = {}
	for k, v in RRule:gmatch('(%a+)=([^;]+)') do R[k] = v end

	local Freq      = R.FREQ
	local Interval  = tonumber(R.INTERVAL) or 1
	local Count     = tonumber(R.COUNT)
	local StartTime = IcsTime(Start)

	local UntilTime
	if R.UNTIL then
		local U = IcsParseDate(R.UNTIL)
		UntilTime = U and IcsTime(U)
	end

	local Results = {}
	local n = 0

	-- Registers one occurrence; returns false when expansion should stop.
	local function Add(D)
		local t = IcsTime(D)
		if t > WindowEnd then return false end
		if UntilTime and (t > UntilTime) then return false end
		n = n + 1
		if Count and (n > Count) then return false end
		if (t >= WindowStart) and not Excluded[IcsDateKey(D)] then
			table.insert(Results, D)
		end
		return true
	end

	if Freq == 'DAILY' then
		local k = 0
		if (not Count) and (StartTime < WindowStart) then
			k = math.max(0, math.floor((WindowStart - StartTime) / (86400 * Interval)) - 1)
		end
		while k < 100000 do
			if not Add(IcsShiftDays(Start, k * Interval)) then break end
			k = k + 1
		end

	elseif Freq == 'WEEKLY' then
		local DayCodes  = { SU = 0, MO = 1, TU = 2, WE = 3, TH = 4, FR = 5, SA = 6 }
		local StartWDay = tonumber(os.date('%w', os.time{ year = Start.year, month = Start.month, day = Start.day, hour = 12 }))
		local Days = {}
		if R.BYDAY then
			for Code in R.BYDAY:gmatch('%a%a') do
				if DayCodes[Code] then table.insert(Days, DayCodes[Code]) end
			end
			table.sort(Days)
		end
		if #Days == 0 then Days = { StartWDay } end

		local w = 0
		if (not Count) and (StartTime < WindowStart) then
			w = math.max(0, math.floor((WindowStart - StartTime) / (604800 * Interval)) - 1)
		end
		local Stop = false
		while (not Stop) and (w < 10000) do
			for _, Day in ipairs(Days) do
				local D = IcsShiftDays(Start, (w * 7 * Interval) + Day - StartWDay)
				if IcsTime(D) >= StartTime then
					if not Add(D) then Stop = true break end
				end
			end
			w = w + 1
		end

	elseif Freq == 'MONTHLY' then
		-- BYDAY rules (e.g. "second Tuesday") are approximated by the
		-- day-of-month of the first occurrence.
		local k = 0
		while k < 2400 do
			local D = IcsShiftMonths(Start, k * Interval)
			if D and not Add(D) then break end
			k = k + 1
		end

	elseif Freq == 'YEARLY' then
		local k = 0
		while k < 200 do
			local D = IcsShiftMonths(Start, k * Interval * 12)
			if D and not Add(D) then break end
			k = k + 1
		end

	else
		Add(Start)
	end

	return Results
end

function ConvertICS(Raw)
	IcsUtcOffset = os.time(os.date('*t')) - os.time(os.date('!*t'))

	-- NORMALIZE AND UNFOLD CONTINUATION LINES
	local s = Raw:gsub('\r\n', '\n')
	s = s:gsub('\n[ \t]', '')

	local CalTitle = s:match('X%-WR%-CALNAME[^:\n]*:([^\n]*)') or 'Google Calendar'

	-- FIRST PASS: COLLECT EVENT BLOCKS AND MODIFIED-INSTANCE DATES
	local Blocks    = {}
	local Overrides = {}
	for Block in s:gmatch('BEGIN:VEVENT\n(.-)END:VEVENT') do
		Block = '\n'..Block
		local UID     = Block:match('\nUID[^:\n]*:([^\n]*)') or ''
		local RecurID = Block:match('\nRECURRENCE%-ID[^:\n]*:([^\n]*)')
		if RecurID then
			local D = IcsParseDate(RecurID)
			if D then
				Overrides[UID] = Overrides[UID] or {}
				Overrides[UID][IcsDateKey(D)] = true
			end
		end
		table.insert(Blocks, { Text = Block, UID = UID, RecurID = RecurID })
	end

	-- TIME WINDOW: START OF TODAY THROUGH ONE YEAR AHEAD
	local Now         = os.date('*t')
	local WindowStart = os.time{ year = Now.year, month = Now.month, day = Now.day, hour = 0, min = 0, sec = 0 }
	local WindowEnd   = WindowStart + (365 * 86400)

	-- SECOND PASS: BUILD OCCURRENCE LIST
	local Items = {}
	for _, B in ipairs(Blocks) do
		local Block  = B.Text
		local Status = Block:match('\nSTATUS[^:\n]*:([^\n]*)')
		local Start  = IcsParseDate(Block:match('\nDTSTART[^:\n]*:([^\n]*)') or '')

		if Start and not (Status and Status:match('CANCELLED')) then
			local Title = Block:match('\nSUMMARY[^:\n]*:([^\n]*)') or 'Untitled'
			local Desc  = Block:match('\nDESCRIPTION[^:\n]*:([^\n]*)') or ''
			local RRule = Block:match('\nRRULE[^:\n]*:([^\n]*)')

			local Occurrences
			if RRule and not B.RecurID then
				local Excluded = {}
				for ExLine in Block:gmatch('\nEXDATE[^:\n]*:([^\n]*)') do
					for ExDate in ExLine:gmatch('[^,]+') do
						local D = IcsParseDate(ExDate)
						if D then Excluded[IcsDateKey(D)] = true end
					end
				end
				if Overrides[B.UID] then
					for k in pairs(Overrides[B.UID]) do Excluded[k] = true end
				end
				Occurrences = IcsExpand(Start, RRule, Excluded, WindowStart, WindowEnd)
			else
				local t = IcsTime(Start)
				Occurrences = ((t >= WindowStart) and (t <= WindowEnd)) and { Start } or {}
			end

			for _, D in ipairs(Occurrences) do
				table.insert(Items, {
					Time  = IcsTime(D),
					Date  = IcsFormatDate(D),
					Title = IcsCleanText(IcsUnescape(Title)),
					Desc  = IcsCleanText(IcsUnescape(Desc):sub(1, 200)),
					UID   = IcsCleanText(B.UID)
					})
			end
		end
	end

	-- SORT UPCOMING AND LIMIT
	table.sort(Items, function(a, b) return a.Time < b.Time end)
	for i = #Items, 21, -1 do
		table.remove(Items)
	end

	-- BUILD LEGACY GCAL ATOM DOCUMENT
	local Lines = {}
	table.insert(Lines, "<feed xmlns:gCal='http://schemas.google.com/gCal/2005'>")
	table.insert(Lines, '<title>'..IcsCleanText(CalTitle)..'</title>')
	table.insert(Lines, "<link rel='alternate' href='https://calendar.google.com/calendar/r'/>")
	for _, Item in ipairs(Items) do
		table.insert(Lines, '<entry>')
		table.insert(Lines, '<id>'..Item.UID..'/'..Item.Date..'</id>')
		table.insert(Lines, '<title>'..Item.Title..'</title>')
		table.insert(Lines, "<link href='https://calendar.google.com/calendar/r'/>")
		table.insert(Lines, '<summary>'..Item.Desc..'</summary>')
		table.insert(Lines, "<gd:when startTime='"..Item.Date.."'/>")
		table.insert(Lines, '</entry>')
	end
	table.insert(Lines, '</feed>')

	return table.concat(Lines, '\n')
end

-----------------------------------------------------------------------
-- TYPES

function DefineTypes()
	Types = {
		RSS = {
			MatchLink     = '<link.->(.-)</link>',
			MatchItem     = '<item.-</item>',
			MatchItemID   = '<guid.->(.-)</guid>',
			MatchItemLink = '<link.->(.-)</link>',
			MatchItemDesc = '<description.->(.-)</description>',
			MatchItemDate = '<pubDate.->(.-)</pubDate>',
			MergeItems    = true,
			ParseDate     = function(s)
				local Date = {}
				local MatchTime = '%a%a%a, (%d%d) (%a%a%a) (%d%d%d%d) (%d%d)%:(%d%d)%:(%d%d) (.-)$'
				local MatchDate = '%a%a%a, (%d%d) (%a%a%a) (%d%d%d%d)$'
				if s:match(MatchTime) then
					Date.day, Date.month, Date.year, Date.hour, Date.min, Date.sec, Date.Offset = s:match(MatchTime)
				elseif s:match(MatchDate) then
					Date.day, Date.month, Date.year = s:match(MatchDate)
				end
				return (Date.year and Date.month and Date.day) and Date or nil
			end
			},
		Atom = {
			MatchLink     = '<link.-href=["\'](.-)["\']',
			MatchItem     = '<entry.-</entry>',
			MatchItemID   = '<id.->(.-)</id>',
			MatchItemLink = '<link.-href=["\'](.-)["\']',
			MatchItemDesc = '<summary.->(.-)</summary>',
			MatchItemDate = '<updated.->(.-)</updated>',
			MergeItems    = true,
			ParseDate     = function(s)
				local Date = {}
				local MatchTime = '(%d%d%d%d)%-(%d%d)%-(%d%d)T(%d%d)%:(%d%d)%:(%d%d)(.-)$'
				local MatchDate = '(%d%d%d%d)%-(%d%d)%-(%d%d)$'
				if s:match(MatchTime) then
					Date.year, Date.month, Date.day, Date.hour, Date.min, Date.sec, Date.Offset = s:match(MatchTime)
				elseif s:match(MatchDate) then
					Date.year, Date.month, Date.day = s:match(MatchDate)
				end
				return Date
			end
			},
		GoogleCalendar = {
			MatchLink     = '<link.-rel=.-alternate.-href=["\'](.-)["\']',
			MatchItem     = '<entry.-</entry>',
			MatchItemID   = '<id.->(.-)</id>',
			MatchItemLink = '<link.-href=["\'](.-)["\']',
			MatchItemDesc = '<summary.->(.-)</summary>',
			MatchItemDate = 'startTime=["\'](.-)["\']',
			MergeItems    = false,
			ParseDate     = function(s)
				local Date = {}
				local MatchTime = '(%d%d%d%d)%-(%d%d)%-(%d%d)T(%d%d)%:(%d%d)%:(%d%d)%.%d+(.-)$'
				local MatchDate = '(%d%d%d%d)%-(%d%d)%-(%d%d)$'
				if s:match(MatchTime) then
					Date.year, Date.month, Date.day, Date.hour, Date.min, Date.sec, Date.Offset = s:match(MatchTime)
				elseif s:match(MatchDate) then
					Date.year, Date.month, Date.day = s:match(MatchDate)
				end
				return Date
			end
			},
		RememberTheMilk = {
			MatchLink     = '<link.-rel=.-alternate.-href=["\'](.-)["\']',
			MatchItem     = '<entry.-</entry>',
			MatchItemID   = '<id.->(.-)</id>',
			MatchItemLink = '<link.-href=["\'](.-)["\']',
			MatchItemDesc = '<summary.->(.-)</summary>',
			MatchItemDate = '<span class=["\']rtm_due_value["\']>(.-)</span>',
			MergeItems    = false,
			ParseDate     = function(s)
				local Date = {}
				local MatchTime = '%a%a%a (%d+) (%a%a%a) (%d+) at (%d+)%:(%d+)(%a%a)' -- e.g. 'Wed 7 Nov 12 at 3:17PM'
				local MatchDate = '%a%a%a (%d+) (%a%a%a) (%d+)' -- e.g. 'Tue 25 Dec 12'
				if s:match(MatchTime) then
					Date.day, Date.month, Date.year, Date.hour, Date.min, Date.Meridiem = s:match(MatchTime)
				elseif s:match(MatchDate) then
					Date.day, Date.month, Date.year = s:match(MatchDate)
				end
				return Date
			end
			}
		}
end

-------------------------

function IdentifyType(s)
	-- COLLAPSE CONTAINER TAGS
	for _, v in ipairs{ 'item', 'entry' } do
		s = s:gsub('<'..v..'.->.+</'..v..'>', '<'..v..'></'..v..'>') -- e.g. '<entry.->.+</entry>' --> '<entry></entry>'
	end

	--DEFINE RSS MARKER TESTS
	--Each of these test functions will be run in turn, until one of them gets a solid match on the format type.
	local TestRSS = {
		function(a)
			-- If the feed contains these tags outside of <item> or <entry>, RSS is confirmed.
			for _, v in ipairs{ '<rss', '<channel', '<lastBuildDate', '<pubDate', '<ttl', '<description' } do
				if a:match(v) then
					return 'RSS'
				end
			end
			return false
		end,

		function(a)
			-- Alternatively, if the feed contains these tags outside of <item> or <entry>, Atom is confirmed.
			for _, v in ipairs{ '<feed', '<subtitle' } do
				if a:match(v) then
					return 'Atom'
				end
			end
			return false
		end,

		function(a)
			-- If no markers are present, we search for <item> or <entry> tags to confirm the type.
			local HaveItems   = a:match('<item')
			local HaveEntries = a:match('<entry')

			if HaveItems and not HaveEntries then
				return 'RSS'
			elseif HaveEntries and not HaveItems then
				return 'Atom'
			else
				-- If both kinds of tags are present, and no markers are given, then I give up
				-- because your feed is ridiculous. And if neither tag is present, then no type
				-- can be confirmed (and there would be no usable data anyway).
				return false
			end
		end
		}

	-- RUN RSS MARKER TESTS
	local Class = false
	for _, v in ipairs(TestRSS) do
		Class = v(s)
		if Class then break end
	end

	-- DETECT SUBTYPE AND RETURN
	if Class == 'RSS' then
		return 'RSS'
	elseif Class == 'Atom' then
		if s:match('xmlns:gCal') then
			return 'GoogleCalendar'
		elseif s:match('<subtitle>rememberthemilk.com</subtitle>') then
			return 'RememberTheMilk'
		else
			return 'Atom'
		end
	else
		return false
	end
end

-------------------------

function IdentifyDate(s, t)
	-- PARSE STRING BY TYPE
	local Date = s and Types[t].ParseDate(s) or {}

	Date.year   = tonumber(Date.year)  or nil
	Date.month  = tonumber(Date.month) or MonthAcronyms[Date.month] or nil
	Date.day    = tonumber(Date.day)   or nil
	Date.hour   = tonumber(Date.hour)  or nil
	Date.min    = tonumber(Date.min)   or nil
	Date.sec    = tonumber(Date.sec)   or 0

	-- FIND ENOUGH ELEMENTS, OR DEFAULT TO RETRIEVAL DATE
	local RealDate, AllDay

	if (Date.year and Date.month and Date.day) then
		RealDate = 1

		-- DETECT ALL-DAY EVENT
		if (Date.hour and Date.min) then
			AllDay    = 0
		else
			AllDay    = 1
			Date.hour = 0
			Date.min  = 0
		end

		-- GET CURRENT LOCAL TIME, UTC OFFSET
		-- These values are referenced in several procedures below.
		local UTC             = os.date('!*t')
		local LocalTime       = os.date('*t')
		local DaylightSavings = LocalTime.isdst and 3600 or 0
		local LocalOffset     = os.time(LocalTime) - os.time(UTC) + DaylightSavings

		-- CHANGE 12-HOUR to 24-HOUR
		if Date.Meridiem then
			if (Date.Meridiem == 'AM') and (Date.hour == 12) then
				Date.hour = 0
			elseif (Date.Meridiem == 'PM') and (Date.hour < 12) then
				Date.hour = Date.hour + 12
			end
		end

		-- FIND CLOSEST MATCH FOR TWO-DIGIT YEAR
		if Date.year < 100 then
			local CurrentYear    = LocalTime.year
			local CurrentCentury = math.floor(CurrentYear / 100) * 100
			local IfThisCentury  = CurrentCentury + Date.year
			local IfNextCentury  = CurrentCentury + Date.year + 100
			if math.abs(CurrentYear - IfThisCentury) < math.abs(CurrentYear - IfNextCentury) then
				Date.year = IfThisCentury
			else
				Date.year = IfNextCentury
			end
		end



		-- GET INPUT OFFSET FROM UTC (OR DEFAULT TO LOCAL)
		if (Date.Offset) and (Date.Offset ~= '') then
			if Date.Offset:match('%a') then
				Date.Offset = TimeZones[Date.Offset] and (TimeZones[Date.Offset] * 3600) or 0
			elseif Date.Offset:match('%d') then
				local Direction, Hours, Minutes = Date.Offset:match('^([^%d]-)(%d+)[^%d]-(%d%d)')

				Direction = Direction:match('%-') and -1 or 1
				Hours     = tonumber(Hours) * 3600
				Minutes   = tonumber(Minutes) and (tonumber(Minutes) * 60) or 0

				Date.Offset = (Hours + Minutes) * Direction
			end
		else
			Date.Offset = LocalOffset
		end

		-- RETURN CONVERTED DATE
		Date     = os.time(Date) + LocalOffset - Date.Offset
	else
		-- NO USABLE DATE FOUND; USE RETRIEVAL DATE INSTEAD
		RealDate = 0
		AllDay   = 0
		Date     = os.time()
	end

	return Date, AllDay, RealDate
end

-----------------------------------------------------------------------
-- EVENT FILE MODULE

function EventFile_Initialize()
	local EventFiles = {}
	local AllEventFiles = SELF:GetOption('EventFile', '')
	for EventFile in AllEventFiles:gmatch('[^%|]+') do
		table.insert(EventFiles, EventFile)
	end
	for i, v in ipairs(Feeds) do
		local EventFile = EventFiles[i] or SELF:GetName()..'_Feed'..i..'Events.xml'
		Feeds[i].EventFile = SKIN:MakePathAbsolute(EventFile)
	end
end

function EventFile_Update(a)
	local f = a or f

	local WriteEvents = SELF:GetNumberOption('WriteEvents', 0)
	if (WriteEvents == 1) and (Feeds[f].Type == 'GoogleCalendar') then
		-- CREATE XML TABLE
		local WriteLines = {}
		table.insert(WriteLines, '<EventFile Title="'..Feeds[f].Title..'">')
		for i, v in ipairs(Feeds[f]) do
			local ItemDate = os.date('*t', v.Date)
			table.insert(WriteLines, '<Event Month="'..ItemDate['month']..'" Day="'..ItemDate['day']..'" Desc="'..v.Title..'"/>')
		end
		table.insert(WriteLines, '</EventFile>')
		
		-- WRITE FILE
		local WriteFile = io.output(Feeds[f].EventFile, 'w')
		if WriteFile then
			local WriteContent = table.concat(WriteLines, '\r\n')
			WriteFile:write(WriteContent)
			WriteFile:close()
		else
			SKIN:Bang('!Log', SELF:GetName()..': cannot open file: '..Feeds[f].EventFile)
		end
	end
end

-----------------------------------------------------------------------
-- HISTORY FILE MODULE

function HistoryFile_Initialize()
	-- DETERMINE FILEPATH
	HistoryFile = SELF:GetOption('HistoryFile', SELF:GetName()..'History.xml')
	HistoryFile = SKIN:MakePathAbsolute(HistoryFile)

	-- CREATE HISTORY DATABASE
	History = {}

	-- CHECK IF FILE EXISTS
	local ReadFile = io.open(HistoryFile)
	if ReadFile then
		local ReadContent = ReadFile:read('*all')
		ReadFile:close()

		-- PARSE HISTORY FROM LAST SESSION
		for ReadFeedURL, ReadFeed in ReadContent:gmatch('<feed URL=(%b"")>(.-)</feed>') do
			local ReadFeedURL = ReadFeedURL:match('^"(.-)"$')
			History[ReadFeedURL] = {}
			for ReadItem in ReadFeed:gmatch('<item>(.-)</item>') do
				local Item = {}
				for Key, Value in ReadItem:gmatch('<(.-)>(.-)</.->') do
					Value = Value:gsub('&lt;', '<')
					Value = Value:gsub('&gt;', '>')
					Item[Key] = Value
				end
				Item.Date = tonumber(Item.Date) or Item.Date
				Item.Unread = tonumber(Item.Unread)
				table.insert(History[ReadFeedURL], Item)
			end
		end
	end

	-- ADD HISTORY TO MAIN DATABASE
	-- For each feed, if URLs match, add all contents from History[h] to Feeds[f].
	for f, Feed in ipairs(Feeds) do
		local h = Feed.Measure:GetOption('URL')
		Feeds[f].URL = h
		if History[h] then
			for _, Item in ipairs(History[h]) do
				table.insert(Feeds[f], Item)
			end
		end
	end
end

function HistoryFile_Update(a)
	local f = a or f

	-- CLEAR AND REBUILD HISTORY
	local h = Feeds[f].URL
	History[h] = {}
	for i, Item in ipairs(Feeds[f]) do
		table.insert(History[h], Item)
	end

	-- WRITE HISTORY IF REQUESTED
	WriteHistory()
end

function WriteHistory()
	local WriteHistory = SELF:GetNumberOption('WriteHistory', 0)
	if WriteHistory == 1 then
		-- GENERATE XML TABLE
		local WriteLines = {}
		for WriteURL, WriteFeed in pairs(History) do
			table.insert(WriteLines, string.format(         '<feed URL=%q>', WriteURL))
			for _, WriteItem in ipairs(WriteFeed) do
				table.insert(WriteLines,                    '\t<item>')
				for Key, Value in pairs(WriteItem) do
					Value = string.gsub(Value, '<', '&lt;')
					Value = string.gsub(Value, '>', '&gt;')
					table.insert(WriteLines, string.format( '\t\t<%s>%s</%s>', Key, Value, Key))
				end
				table.insert(WriteLines,                    '\t</item>')
			end
			table.insert(WriteLines,                        '</feed>')
		end

		-- WRITE XML TO FILE
		local WriteFile = io.open(HistoryFile, 'w')
		if WriteFile then
			local WriteContent = table.concat(WriteLines, '\n')
			WriteFile:write(WriteContent)
			WriteFile:close()
		else
			SKIN:Bang('!Log', SELF:GetName()..': cannot open file: '..HistoryFile)
		end
	end
end

function ClearHistory()
	local DeleteFile = io.open(HistoryFile)
	if DeleteFile then
		DeleteFile:close()
		os.remove(HistoryFile)
		SKIN:Bang('!Log', SELF:GetName()..': deleted history cache at '..HistoryFile)
	end
	SKIN:Bang('!Refresh')
end

-----------------------------------------------------------------------
-- CONSTANTS

TimeZones = {
	IDLW = -12, --  International Date Line West 
	NT   = -11, --  Nome 
	CAT  = -10, --  Central Alaska 
	HST  = -10, --  Hawaii Standard 
	HDT  = -9,  --  Hawaii Daylight 
	YST  = -9,  --  Yukon Standard 
	YDT  = -8,  --  Yukon Daylight 
	PST  = -8,  --  Pacific Standard 
	PDT  = -7,  --  Pacific Daylight 
	MST  = -7,  --  Mountain Standard 
	MDT  = -6,  --  Mountain Daylight 
	CST  = -6,  --  Central Standard 
	CDT  = -5,  --  Central Daylight 
	EST  = -5,  --  Eastern Standard 
	EDT  = -4,  --  Eastern Daylight 
	AST  = -3,  --  Atlantic Standard 
	ADT  = -2,  --  Atlantic Daylight 
	WAT  = -1,  --  West Africa 
	GMT  =  0,  --  Greenwich Mean 
	UTC  =  0,  --  Universal (Coordinated) 
	Z    =  0,  --  Zulu, alias for UTC 
	WET  =  0,  --  Western European 
	BST  =  1,  --  British Summer 
	CET  =  1,  --  Central European 
	MET  =  1,  --  Middle European 
	MEWT =  1,  --  Middle European Winter 
	MEST =  2,  --  Middle European Summer 
	CEST =  2,  --  Central European Summer 
	MESZ =  2,  --  Middle European Summer 
	FWT  =  1,  --  French Winter 
	FST  =  2,  --  French Summer 
	EET  =  2,  --  Eastern Europe, USSR Zone 1 
	EEST =  3,  --  Eastern European Daylight 
	WAST =  7,  --  West Australian Standard 
	WADT =  8,  --  West Australian Daylight 
	CCT  =  8,  --  China Coast, USSR Zone 7 
	JST  =  9,  --  Japan Standard, USSR Zone 8 
	EAST = 10,  --  Eastern Australian Standard 
	EADT = 11,  --  Eastern Australian Daylight 
	GST  = 10,  --  Guam Standard, USSR Zone 9 
	NZT  = 12,  --  New Zealand 
	NZST = 12,  --  New Zealand Standard 
	NZDT = 13,  --  New Zealand Daylight 
	IDLE = 12   --  International Date Line East 
	}

MonthAcronyms = {
	Jan = 1,
	Feb = 2,
	Mar = 3,
	Apr = 4,
	May = 5,
	Jun = 6,
	Jul = 7,
	Aug = 8,
	Sep = 9,
	Oct = 10,
	Nov = 11,
	Dec = 12
	}