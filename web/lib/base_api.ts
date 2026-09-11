'use client'

import axios from 'axios'


export default function api() {
  const instance = axios.create({
    baseURL: 'http://localhost:8040',
    headers: {
      'Content-Type': 'application/json',
    },
    withCredentials: true
  })
  instance.maxContentLength = 10 * 1024 * 1024 // 10M
  instance.maxBodyLength = 10 * 1024 * 1024

  instance.interceptors.request.use(
    (config) => {
      console.log('[Axios] req', `${config.method}: ${config.url}`, config.data)

      return config
    },
    (error) => {
      return Promise.reject(error)
    }
  )

  instance.interceptors.response.use(
    (res) => {
      console.log('[Axios] res', `${res.config.method}: ${res.config.url}`, res.status, res.data)
      return res
    },
    (error) => {
      if (error.response) {
        console.log('[Axios] error', error.response.status, error.response)
      } else {
        console.log('[Axios] error', error)
      }

      return Promise.reject(error)
    }
  )
  return instance
}
