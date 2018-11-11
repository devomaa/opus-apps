local itemDB = require('itemDB')
local UI     = require('ui')
local Util   = require('util')

local device = _G.device

local exportView = UI.Window {
	title = 'Export item into machine',
	index = 3,
	grid = UI.ScrollingGrid {
		x = 2, ex = -6, y = 2, ey = -4,
		columns = {
			{ heading = 'Slot',   key = 'slot', width = 4 },
			{ heading = 'Filter', key = 'filter' },
		},
		sortColumn = 'slot',
		help = 'Edit this entry',
	},
	text = UI.Text {
		x = 2, y = -2,
		value = 'Slot',
	},
	slots = UI.Chooser {
		x = 7, y = -2,
		width = 7,
		nochoice = 'All',
		help = 'Export to this slot',
	},
	add = UI.Button {
		x = 15, y = -2,
		text = '+', event = 'add_entry', help = 'Add',
	},
	remove = UI.Button {
		x = -4, y = 4,
		text = '-', event = 'remove_entry', help = 'Remove',
	},
}

function exportView:isValidFor(node)
	return node.mtype == 'machine'
end

function exportView:setNode(node)
	self.machine = node
	if not self.machine.exports then
		self.machine.exports = { }
	end
	self.grid:setValues(self.machine.exports)

	self.slots.choices = {
		{ name = 'All', value = '*' }
	}

	local m = device[self.machine.name]
		for k = 1, m.size() do
		table.insert(self.slots.choices, { name = k, value = k })
	end
end

function exportView.grid:getDisplayValues(row)
	row = Util.shallowCopy(row)
	if not row.filter or Util.empty(row.filter) then
		row.filter = 'none'
	else
		local t = { }
		for key in pairs(row.filter) do
			table.insert(t, itemDB:getName(key))
		end
		row.filter = table.concat(t, ', ')
	end
	return row
end

function exportView:eventHandler(event)
	if event.type == 'grid_select' then
		self:emit({
			type = 'edit_filter',
			entry = self.grid:getSelected(),
			whitelistOnly = true,
			callback = function()
				self.grid:update()
				self.grid:draw()
			end,
		})

	elseif event.type == 'add_entry' then
		table.insert(self.machine.exports, {
			slot = self.slots.value or '*',
			filter = { },
		})
		self.grid:update()
		self.grid:draw()

	elseif event.type == 'remove_entry' then
		local row = self.grid:getSelected()
		if row then
			Util.removeByValue(self.grid.values, row)
			self.grid:update()
			self.grid:draw()
		end
	end
end

UI:getPage('nodeWizard').wizard:add({ export = exportView })