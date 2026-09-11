import { usePathname } from 'next/navigation'

export function owlPath() {
  const current = usePathname()
  const paths = current.split('/').filter((x) => x != '')
  const filepath = paths.slice(1, paths.length)
                    .join('/')
                    .replaceAll('.toml', '')
                    .replaceAll('.xml', '')
                  
  const res = {
    repo: paths[0],
    filepath: filepath,
    current: current,
  }
  return res
}


export function joinpath(path, filename) {
  if (path.length == 0) {
    return `./${filename}`
  }
  const result = path
    .replace(/[^a-zA-Z0-9_\-./]/g, '')
    .replace(/\/+/g, '/')
    .replace(/\/$/, '')
    .replace(/\.{2,}/g, '')
  if (result.startsWith('.')) {
    return `${result}/${filename}`
  } else if (result.startsWith('/')) {
    return `.${result}/${filename}`
  } else if (result.length == 0) {
    return `./${filename}`
  }
  return `./${result}/${filename}`
}
