'use client'

import {
  Link,
  TableContainer,
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableRow,
  Paper,
  Typography,
  Box,
}
from '@mui/material'

import type { FileItem } from '@/types/git'

type FileViewProps = {
  repo: string,
  files: FileItem[],
  onNavigate: (FileItem) => void,
}


const repo = 'isskj'

export default function FileView({ repo, files, onNavigate }: Props) {
  return (
    <TableContainer component={Paper}>
      <Table>
         <TableHead>
           <TableRow>
             <TableCell>
               File Name
             </TableCell>
             <TableCell>
               Size
             </TableCell>
             <TableCell>
               Updated
             </TableCell>
           </TableRow>
         </TableHead>

         <TableBody>
           {files.map((file) => (
             <TableRow
               key={file.name}
               hover
               sx={{
                 textDecoration: 'none',
               }}
             >
               <TableCell>
                 <Link
                   component='button'
                   onClick={() => onNavigate(file) }
                   style={{
                     pointerEvents: file.canload ? 'auto' : 'none',
                     color: file.canload ? 'primary.main' : 'text.disabled',
                     cursor: file.canload ? 'pointer' : 'default',
                     textDecoration: 'none',
                   }}
                 >
                 {file.name}
                 </Link>
               </TableCell>

               <TableCell>
                 {file.size}
               </TableCell>

               <TableCell>
                 {file.updated}
               </TableCell>
             </TableRow>
           ))}
        </TableBody>
      </Table>
    </TableContainer>
  )
}
