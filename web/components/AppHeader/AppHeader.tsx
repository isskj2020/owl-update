'use client'

import {
  AppBar,
  Link,
  Toolbar,
  Typography,
  Chip,
  Box,
  Button,
} from '@mui/material'

type AppHeaderProps = {
  children: ReactNode
}


export default function AppHeader({ children }: AppHeaderProps) {

  return (
    <AppBar
      position='static'
      elevation={3}
    >
      <Toolbar>
        <Box sx={{ flexGrow: 1 }}>
          <Link href='/' color='inherit'>
          <Typography
            variant='h6'
            component='div'
            sx={{
              fontWeight: 700,
              letterSpacing: '0.05em',
            }}
          >
            OWLUpdate
          </Typography>
          </Link>
        </Box>
        {children}
      </Toolbar>
    </AppBar>
  )
}

