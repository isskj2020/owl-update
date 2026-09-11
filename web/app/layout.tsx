import type { Metadata } from 'next'
import './globals.css'
import { Roboto } from 'next/font/google'
import AppHeader from '@/components/AppHeader/AppHeader'
import { Stack } from '@mui/material'
import AppThemeProvider from '@/components/AppThemeProvider'
import { useObjectState } from '@/lib/react'
import type { User } from '@/types/types'
import { apiAuth, errorMessage } from '@/lib/api'
import Auth from './Auth'
import {
  Box,
} from '@mui/material'


const roboto = Roboto({
  subsets: ['latin'],
})


export const metadata: Metadata = {
  title: 'OWL Evolution Tool',
  description: '',
}

export default function RootLayout({ children }: RootLayoutProps) {
  return (
    <>
      <html lang='en' suppressHydrationWarning>
        <body className={roboto.className}>
          <AppThemeProvider>
            <Stack>
              <AppHeader>
                <Auth />
              </AppHeader>
              <Box
                sx={{
                  p: 2,
                }}
              >
              {children}
              </Box>
            </Stack>
          </AppThemeProvider>
        </body>
      </html>
    </>
  )
}
