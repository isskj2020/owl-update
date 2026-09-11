import { useState, useCallback } from 'react'

export function useObjectState<T extends object>(initState: T) {
  const [state, setState] = useState(initState)

  const update = useCallback((patch: Partial<T>) => {
    setState((prev) => ({ ...prev, ...patch, }))
  }, [])

  return [ state, update ] as const
}
