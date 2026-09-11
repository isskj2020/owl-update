'use client'

import { Box } from '@mui/material'
import { ReactNode } from 'react'

import {
  Group,
  Panel,
  Separator,
} from 'react-resizable-panels'

type Props = {
  editor: ReactNode
  graph: ReactNode
}


export default function EditorPane({ editor, graph }: Props) {
  return (
    <Box
      sx={{
        width: '100%',
        height: '100vh',
        display: 'flex',
        flexDirection: 'column',
      }}
    >
      <Group
        orientation='horizontal'
        style={{
          height: '100%',
          width: '100%',
          flex: 1,
          display: 'flex',
        }}>
        <Panel defaultSize='55%'>
          <Box
            sx={{
              width: '100%',
              height: '100%',
              flex: 1,
              display: 'flex',
            }}
          >
            {editor}
          </Box>
        </Panel>
  
        <Separator
          style={{
            width: '8px',
            border: '1px solid #ccc',
            cursor: 'col-resize',
          }}
        />
  
        <Panel defaultSize='45%'>
          <Box
            sx={{
              width: '100%',
              height: '100%',
              minWidth: 0,
              minHeight: 0,
              overflow: 'hidden',
            }}
          >
            {graph}
          </Box>
        </Panel>
      </Group>
    </Box>
  )
}
