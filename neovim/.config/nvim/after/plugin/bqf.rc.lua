local status, bqf = pcall(require, 'bqf')
if (not status) then return end

bqf.setup {
  auto_resize_height = true, -- highly recommended enable
}
