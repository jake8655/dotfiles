require('lualine').setup {
  sections = {
    lualine_x = { 'fileformat', 'filetype' },
    lualine_y = { 'progress', 'location' },
    lualine_z = { "os.date('%H:%M:%S')" },
    lualine_c = {
      {
        'filename',
        file_status = true,
        path = 1,
      },
    },
  },
}
