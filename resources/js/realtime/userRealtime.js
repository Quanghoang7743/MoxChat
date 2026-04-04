import { getEcho, initEcho } from './echoClient.js'

const noop = () => {}

const resolveEcho = (token) => {
  const existing = getEcho()
  if (existing) {
    return existing
  }

  const fallbackToken = token || window.localStorage?.getItem('messapp_auth_token')
  if (!fallbackToken) {
    return null
  }

  return initEcho(fallbackToken)
}

export const subscribeUserChannel = (userId, handlers = {}, token = null) => {
  if (!userId) {
    return noop
  }

  let attempts = 0
  let timerId = null
  let left = false
  let leave = noop

  const subscribe = () => {
    if (left) {
      return
    }

    const echo = resolveEcho(token)
    if (!echo) {
      if (attempts < 5) {
        attempts += 1
        timerId = window.setTimeout(subscribe, 300)
      }
      return
    }

    const channelName = `user.${userId}`
    const channel = echo.private(channelName)

    channel.listen('.friend.request.received', (payload) => handlers.onFriendRequestReceived?.(payload))
    channel.listen('.friend.request.accepted', (payload) => handlers.onFriendRequestAccepted?.(payload))
    channel.listen('.friend.request.rejected', (payload) => handlers.onFriendRequestRejected?.(payload))
    channel.listen('.friend.removed', (payload) => handlers.onFriendRemoved?.(payload))
    channel.listen('.conversation.participant.settings.updated', (payload) => handlers.onConversationSettingsUpdated?.(payload))

    leave = () => {
      echo.leave(channelName)
    }
  }

  subscribe()

  return () => {
    left = true
    if (timerId) {
      window.clearTimeout(timerId)
    }
    leave()
  }
}
