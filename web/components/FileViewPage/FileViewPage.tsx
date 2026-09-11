'use client'

import {
  Alert,
  Typography,
  Box,
  Item,
  Link,
  Button,
  Stack,
  LinearProgress,
}
from '@mui/material'
import { useObjectState } from '@/lib/react'
import FileMenuButton from '@/components/FileMenu/FileMenuButton'
import FileView from './FileView'

import type { ApiState, FileItem } from '@/types/types'


type FileViewPageProps = {
  repository: string,
  apiState: ApiState,
  files: FileItem[],
  onAddDirectory: (path: string) => void,
  onAddFile: (path: string, file: File) => void,
  onNavigate: (url: string) => void,
}

export default function FileViewPage({
  repository,
  apiState,
  files,
  onAddDirectory,
  onAddFile,
  onNavigate,
}: FileViewPageProps) {

  return (
    <Box sx={{
      p: 3,
    }}>
      {apiState.loading && (
        <Box sx={{
          width: '100%',
          p: 4,
        }}>
          <LinearProgress />
        </Box>
      )}
      {apiState.error && (
        <Alert severity='error'>
          {apiState.error}
        </Alert>
      )}


      <Box sx={{
        display: 'flex',
        m: 2,
      }}>
        <Box sx={{ flexGrow: 1 }}>
          <Typography
            variant='h5'
            sx={{ mb: 2, fontWeight: 600 }}
          >
            Repository Files
          </Typography>
        </Box>
        <Box sx={{ mr: 2 }}>
          <FileMenuButton 
            onAddDirectory={onAddDirectory}
            onAddFile={onAddFile}
          />
        </Box>
        <Box sx={{ ml: 2 }}>
          <Button
            onClick={() => onNavigate(`/${repository}/logs`) }
            variant='outlined'
            color='inherit'
            >
            Git logs
          </Button>
        </Box>
      </Box>
      <FileView repo={repository} files={files} onNavigate={(file) => {
        onNavigate(`/${repository}/${file.name}`)
      }} />
    </Box>
  )
}
