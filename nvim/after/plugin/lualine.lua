require('lualine').setup {
  sections = {
    lualine_x = { 'fileformat', 'filetype' },
    lualine_y = { 'progress', 'location' },
    lualine_z = { "os.date('%H:%m:%S')" },
  },
}
