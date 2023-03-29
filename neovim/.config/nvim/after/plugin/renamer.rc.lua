local status, renamer = pcall(require, 'renamer')
if (not status) then return end

renamer.setup {}
