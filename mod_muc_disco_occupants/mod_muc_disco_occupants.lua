-- luacheck: globals module
-- SPDX-License-Identifier: MIT
module:depends'muc'

local FIELDNAME = "{xmpp:prosody.im}muc#roomconfig_discover_occupants"

local st = require'util.stanza'

local on_by_default = module:get_option_boolean("muc_room_default_discover_occupants", false)

local function should_list_occupants(room)
	local list_occupants = room._data.list_occupants
	if list_occupants == nil then
		list_occupants = on_by_default
	end
	return list_occupants
end

module:hook("muc-config-form", function(event)
	local room, form = event.room, event.form
	table.insert(form, {
		name = FIELDNAME,
    type = "boolean",
    label = "Allow listing occupants via service discovery",
    value = should_list_occupants(room)
  })
end)

module:hook("muc-config-submitted", function(event)
  local room, fields, changed = event.room, event.fields, event.changed
  local list_occupants = fields[FIELDNAME]
  if list_occupants ~= should_list_occupants(room) then
    if type(changed) == "table" then
      changed[FIELDNAME] = true
    else
      event.changed = true
    end
    room._data.list_occupants = list_occupants
  end
end)

local function get_disco_items(room,stanza)
	local reply = st.reply(stanza):query("http://jabber.org/protocol/disco/#items")
	if should_list_occupants(room) then
		for occupant_jid in room:each_occupant() do
			reply:tag("item", { jid = occupant_jid }):up()
		end
	end

	return reply
end

module:hook('muc-room-restored', function(event)
	event.room.get_disco_items = get_disco_items
end)

module:hook('muc-room-created', function(event)
	event.room.get_disco_items = get_disco_items
end)
