'use client'

import {
  Box,
} from '@mui/material'

type Props = {
  diff: string
}

export default function DiffView({ diff }: Props) {
  const lines = diff.split('\n')

  return (
    <Box
      sx={{
        height: 300,
        overflow: 'auto',
        border: '1px solid',
        borderColor: 'divider',
        borderRadius: 1,
        fontFamily: 'monospace',
      }}
    >
      {lines.map((line, index) => {
        let color = 'inherit'
        if (line.startsWith('+++ ') || line.startsWith('--- ')) {
          color = 'secondary.main'
        } else if (line.startsWith('+')) {
          color = 'success.main'
        } else if (line.startsWith('-')) {
          color = 'error.main'
        }

        return (
          <Box
            key={index}
            sx={{
              color,
              whiteSpace: 'pre',
            }}
          >
            {line}
          </Box>
        )
      })}
    </Box>
  )
}
