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

export const subscribeConversationChannel = (conversationId, handlers = {}, token = null) => {
  if (!conversationId) {
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

    const channelName = `conversation.${conversationId}`
    const channel = echo.private(channelName)

    channel.listen('.message.created', (payload) => handlers.onMessageCreated?.(payload))
    channel.listen('.message.updated', (payload) => handlers.onMessageUpdated?.(payload))
    channel.listen('.message.deleted_for_everyone', (payload) => handlers.onMessageDeletedForEveryone?.(payload))
    channel.listen('.message.reaction.changed', (payload) => handlers.onReactionChanged?.(payload))
    channel.listen('.conversation.read.updated', (payload) => handlers.onReadUpdated?.(payload))
    channel.listen('.conversation.delivered.updated', (payload) => handlers.onDeliveredUpdated?.(payload))
    channel.listen('.conversation.typing.updated', (payload) => handlers.onTypingUpdated?.(payload))

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

export const joinConversationPresence = (conversationId, handlers = {}, token = null) => {
  if (!conversationId) {
    return noop
  }

  let attempts = 0
  let timerId = null
  let left = false
  let leave = noop

  const join = () => {
    if (left) {
      return
    }

    const echo = resolveEcho(token)
    if (!echo) {
      if (attempts < 5) {
        attempts += 1
        timerId = window.setTimeout(join, 300)
      }
      return
    }

    const channelName = `conversation-presence.${conversationId}`

    echo
      .join(channelName)
      .here((users) => handlers.onHere?.(users))
      .joining((user) => handlers.onJoining?.(user))
      .leaving((user) => handlers.onLeaving?.(user))
      .error((error) => handlers.onError?.(error))

    leave = () => {
      echo.leave(channelName)
    }
  }

  join()

  return () => {
    left = true
    if (timerId) {
      window.clearTimeout(timerId)
    }
    leave()
  }
}
