import { extendTheme } from '@mui/material/styles'

export const theme = extendTheme({
  cssVariables: true,
  colorSchemes: {
    dark: {
      palette: {
        primary: {
          light: '#6ba6ff',
          main: '#2f82f7',
          dark: '#1558b0',
          contrastText: '#f0f6fd',
        },

        secondary: {
          light: '#5debf2',
          main: '#00c2cd',
          dark: '#00838f',
          contrastText: '#001012',
        },

        graph: {
          thing: '#111827',
          subclass: '#334155',
          disjoint: '#7f3342',
          violated: '#f9423d',
          line: '#00ffff',
          text: '#ffffff',
        },

        success: {
          light: '#5ddf91',
          main: '#00a14c',
          dark: '#007936',
          contrastText: '#030f05',
        },

        warning: {
          light: '#ffd166',
          main: '#de9a00',
          dark: '#a66f00',
          contrastText: '#1c0f00',
        },

        error: {
          light: '#ff7672',
          main: '#f9423d',
          dark: '#b71c1c',
          contrastText: '#160605',
        },

        info: {
          light: '#4fc3f7',
          main: '#008ecc',
          dark: '#006494',
          contrastText: '#000d15',
        },

        background: {
          default: '#050c1e',
          paper: '#020511',
        },

        text: {
          primary: '#dae2ef',
          secondary: '#8ea4d0',
        },

        divider: '#1b263f',
      },
    },

    light: {
      palette: {
        primary: {
          light: '#6ba6ff',
          main: '#1565c0',
          dark: '#003c8f',
          contrastText: '#ffffff',
        },

        secondary: {
          light: '#5debf2',
          main: '#0097a7',
          dark: '#006978',
          contrastText: '#ffffff',
        },

        graph: {
          thing: '#475569',
          subclass: '#64748b',
          disjoint: '#b45363',
          violated: '#d32f2f',
          line: '#292524',
          text: '#234323',
        },

        success: {
          light: '#81c995',
          main: '#008a42',
          dark: '#00652f',
          contrastText: '#ffffff',
        },

        warning: {
          light: '#ffd166',
          main: '#c47f00',
          dark: '#8a5800',
          contrastText: '#ffffff',
        },

        error: {
          light: '#ff8a85',
          main: '#d32f2f',
          dark: '#9a0007',
          contrastText: '#ffffff',
        },

        info: {
          light: '#4fc3f7',
          main: '#0277bd',
          dark: '#004c8c',
          contrastText: '#ffffff',
        },

        background: {
          default: '#f5f8fc',
          paper: '#ffffff',
        },

        text: {
          primary: '#102033',
          secondary: '#526070',
        },

        divider: '#d5dce8',
      },
    },
  },

  spacing: 8,

  shape: {
    borderRadius: 8,
  },
})
