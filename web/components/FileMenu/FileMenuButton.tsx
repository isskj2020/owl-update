'use client'

import { useState, MouseEvent } from 'react'
import {
  Button,
  Menu,
  MenuItem,
  ListItemIcon,
  ListItemText,
} from '@mui/material'
import ArrowDropDownIcon from '@mui/icons-material/ArrowDropDown'
import CreateNewFolderIcon from '@mui/icons-material/CreateNewFolder'
import NoteAddIcon from '@mui/icons-material/NoteAdd'
import UploadFileIcon from '@mui/icons-material/UploadFile'
import { useObjectState } from '@/lib/react'
import NewFolderDialog from './NewFolderDialog'
import UploadFileDialog from './UploadFileDialog'

type DialogOpen = {
  newFolder: boolean,
  uploadFile: boolean,
}

type FileMenuButtonProps  = {
  onAddDirectory: (path: string) => void,
  onAddFile: (path: string, file: File) => void,
}

export default function FileMenuButton({
  onAddDirectory,
  onAddFile,
}: FileMenuButtonProps) {
  const [anchor, setAnchor] = useState<null | HTMLElement>(null)
  const [dialog, updateDialog] = useObjectState<DialogOpen>({
    newFolder: false,
    uploadFile: false,
  })

  const onMenuOpen = (event: MouseEvent<HTMLButtonElement>) => {
    setAnchor(event.currentTarget)
  }

  const onMenuClose = () => {
    setAnchor(null)
  }

  const onMenuClick = (dialog: DialogOpen) => {
    onMenuClose()
    updateDialog(dialog)
  }

  return (
    <>
      <Button
        variant='contained'
        endIcon={<ArrowDropDownIcon />}
        onClick={onMenuOpen}
      >
        Add Files
      </Button>
      <NewFolderDialog 
        open={dialog.newFolder}
        onCreate={(path) => {
          updateDialog({ newFolder: false})
          onAddDirectory(path)
        }}
        onClose={() => updateDialog({ newFolder: false })}
      />
      <UploadFileDialog
        open={dialog.uploadFile}
        onUpload={(path, file) => {
          updateDialog({ uploadFile: false })
          onAddFile(path, file)
        }}
        onClose={() => updateDialog({ uploadFile: false })}
      />


      <Menu
        anchorEl={anchor}
        open={Boolean(anchor)}
        onClose={onMenuClose}
      >
        <MenuItem onClick={() => onMenuClick({ newFolder: true })}>
          <ListItemIcon>
            <CreateNewFolderIcon fontSize='small' />
          </ListItemIcon>
          <ListItemText>New Folder</ListItemText>
        </MenuItem>

        <MenuItem onClick={() => onMenuClick({ uploadFile: true })}>
          <ListItemIcon>
            <UploadFileIcon fontSize='small' />
          </ListItemIcon>
          <ListItemText>Upload File</ListItemText>
        </MenuItem>
      </Menu>
    </>
  )
}
