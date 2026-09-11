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
import { useObjectState } from '@/lib/react'


type MLButtonMenuProps  = {
  onSuggestML: (type: string) => void,
}

export default function MLButtonMenu({
  onSuggestML,
}: MLButtonMenuProps) {
  const [anchor, setAnchor] = useState<null | HTMLElement>(null)

  const onMenuOpen = (event: MouseEvent<HTMLButtonElement>) => {
    setAnchor(event.currentTarget)
  }

  const onMenuClose = () => {
    setAnchor(null)
  }

  const onMenuClick = (type: string) => {
    onMenuClose()
    onSuggestML(type)
  }

  return (
    <>
      <Button
        variant='contained'
        endIcon={<ArrowDropDownIcon />}
        onClick={onMenuOpen}
      >
        Suggest by ML
      </Button>

      <Menu
        anchorEl={anchor}
        open={Boolean(anchor)}
        onClose={onMenuClose}
      >
        <MenuItem onClick={() => onMenuClick('llm')}>
          <ListItemText>Local LLM</ListItemText>
        </MenuItem>

        <MenuItem onClick={() => onMenuClick('embedding')}>
          <ListItemText>Local Embedding</ListItemText>
        </MenuItem>
      </Menu>
    </>
  )
}
