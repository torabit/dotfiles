local status, notifer = pcall(require, 'notifier')
if (not status) then return end

notifer.setup {}
