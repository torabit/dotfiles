local status, newpaper = pcall(require, 'newpaper')
if (not status) then return end

newpaper.setup {
  style = 'light',
  disable_background = true,
  italic_strings = false,
  italic_comments = false,
}
