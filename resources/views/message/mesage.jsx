import {
  Avatar,
  Box,
  Button,
  Card,
  CardContent,
  CircularProgress,
  Divider,
  Drawer,
  Stack,
  TextField,
  Typography,
} from '@mui/material'
import React from 'react'
import { motion } from 'motion/react'
import ChatListPanel from './components/sidebar/ChatListPanel.jsx'
import ConversationPanel from './components/ConversationPanel.jsx'
import { useAuth } from '../../js/context/AuthContext.jsx'
import { conversationsApi } from '../../js/api/conversationsApi.js'
import { friendsApi } from '../../js/api/friendsApi.js'
import { messagesApi } from '../../js/api/messagesApi.js'
import { usersApi } from '../../js/api/usersApi.js'
import { devicesApi } from '../../js/api/devicesApi.js'
import { asConversationCollection, asFriendCollection, toArray } from '../../js/utils/dataShape.js'
import { createClientMessageId } from '../../js/utils/chatIds.js'
import { toApiError } from '../../js/api/response.js'
import { joinConversationPresence, subscribeConversationChannel } from '../../js/realtime/conversationRealtime.js'
import { subscribeUserChannel } from '../../js/realtime/userRealtime.js'
import { buildDevicePayload } from '../../js/utils/deviceIdentity.js'

const MESSAGE_PAGE_SIZE = 30

const uniqueById = (items) => {
  const map = new Map()

  items.forEach((item) => {
    map.set(String(item.id), item)
  })

  return Array.from(map.values())
}

const toMysqlDatetime = (date) => {
  const pad = (value) => value.toString().padStart(2, '0')

  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} ${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}`
}

const buildProfileForm = (user) => ({
  display_name: user?.display_name || '',
  username: user?.username || '',
  email: user?.email || '',
  phone_number: user?.phone_number || '',
  avatar_url: user?.avatar_url || '',
  bio: user?.bio || '',
  gender: user?.gender || '',
  birth_date: user?.birth_date || '',
  presence_status: user?.presence_status || 'offline',
  password: '',
})

const buildDeviceForm = () => ({
  device_uuid: '',
  device_type: 'web',
  device_name: '',
  push_token: '',
  app_version: '',
  os_version: '',
})

export default function Mesage() {
  const { user, token, logout, setUser } = useAuth()

  const [darkMode] = React.useState(false)
  const [conversations, setConversations] = React.useState([])
  const [activeConversationId, setActiveConversationId] = React.useState(null)
  const [messagesByConversation, setMessagesByConversation] = React.useState({})
  const [participantsByConversation, setParticipantsByConversation] = React.useState({})
  const [presenceUsers, setPresenceUsers] = React.useState([])
  const [typingUsers, setTypingUsers] = React.useState({})

  const [loadingConversations, setLoadingConversations] = React.useState(false)
  const [loadingMessages, setLoadingMessages] = React.useState(false)
  const [loadingParticipants, setLoadingParticipants] = React.useState(false)

  const [searchKeyword, setSearchKeyword] = React.useState('')
  const [searchResults, setSearchResults] = React.useState([])
  const [searchLoading, setSearchLoading] = React.useState(false)

  const [friends, setFriends] = React.useState([])
  const [incomingRequests, setIncomingRequests] = React.useState([])
  const [outgoingRequests, setOutgoingRequests] = React.useState([])

  const [composerText, setComposerText] = React.useState('')
  const [composerType, setComposerType] = React.useState('text')
  const [composerAttachment, setComposerAttachment] = React.useState(null)
  const [sending, setSending] = React.useState(false)

  const [newParticipantIdsInput, setNewParticipantIdsInput] = React.useState('')

  const [drawerMode, setDrawerMode] = React.useState(null)
  const [profileForm, setProfileForm] = React.useState(buildProfileForm(user))
  const [profileSaving, setProfileSaving] = React.useState(false)

  const [devices, setDevices] = React.useState([])
  const [devicesLoading, setDevicesLoading] = React.useState(false)
  const [deviceForm, setDeviceForm] = React.useState(buildDeviceForm())
  const [deviceSaving, setDeviceSaving] = React.useState(false)

  const [requestProcessingId, setRequestProcessingId] = React.useState(null)

  const activeConversationIdRef = React.useRef(null)
  const messagesByConversationRef = React.useRef({})
  const searchDebounceRef = React.useRef(null)
  const typingDebounceRef = React.useRef(null)
  const typingStopRef = React.useRef(null)
  const remoteTypingTimeoutRef = React.useRef({})
  const receiptsRef = React.useRef({})

  const notify = React.useCallback((message) => {
    if (!message) {
      return
    }

    window.alert(message)
  }, [])

  React.useEffect(() => {
    setProfileForm(buildProfileForm(user))
  }, [user])

  React.useEffect(() => {
    activeConversationIdRef.current = activeConversationId
  }, [activeConversationId])

  React.useEffect(() => {
    messagesByConversationRef.current = messagesByConversation
  }, [messagesByConversation])

  const currentConversation = React.useMemo(
    () => conversations.find((conversation) => Number(conversation.id) === Number(activeConversationId)) || null,
    [activeConversationId, conversations],
  )

  const currentMessagesState = messagesByConversation[String(activeConversationId)] || { items: [], hasMore: false }
  const currentMessagesDesc = currentMessagesState.items || []

  const currentMessagesAsc = React.useMemo(() => {
    return [...currentMessagesDesc].sort((a, b) => {
      const aid = Number(a.id)
      const bid = Number(b.id)

      if (Number.isFinite(aid) && Number.isFinite(bid)) {
        return aid - bid
      }

      return String(a.id).localeCompare(String(b.id))
    })
  }, [currentMessagesDesc])

  const currentParticipants = participantsByConversation[String(activeConversationId)] || []

  const role = currentConversation?.my_participant_settings?.participant_role || 'member'
  const isOwner = role === 'owner'
  const isOwnerOrAdmin = role === 'owner' || role === 'admin'

  const relationByUserId = React.useMemo(() => {
    const map = {}

    friends.forEach((row) => {
      if (row?.friend?.id) {
        map[String(row.friend.id)] = { type: 'friend' }
      }
    })

    incomingRequests.forEach((row) => {
      if (row?.status === 'pending' && row?.requester?.id) {
        map[String(row.requester.id)] = { type: 'incoming', requestId: row.id }
      }
    })

    outgoingRequests.forEach((row) => {
      if (row?.status === 'pending' && row?.addressee?.id) {
        map[String(row.addressee.id)] = { type: 'outgoing', requestId: row.id }
      }
    })

    return map
  }, [friends, incomingRequests, outgoingRequests])

  const latestMessageId = React.useMemo(() => {
    const ids = currentMessagesDesc
      .map((message) => Number(message.id))
      .filter((id) => Number.isFinite(id))

    if (ids.length === 0) {
      return null
    }

    return Math.max(...ids)
  }, [currentMessagesDesc])

  const fetchFriendData = React.useCallback(async () => {
    try {
      const [friendsPayload, incomingPayload, outgoingPayload] = await Promise.all([
        friendsApi.list({ per_page: 100 }),
        friendsApi.incoming({ per_page: 100 }),
        friendsApi.outgoing({ per_page: 100 }),
      ])

      setFriends(asFriendCollection(friendsPayload).items)
      setIncomingRequests(toArray(incomingPayload?.items || incomingPayload))
      setOutgoingRequests(toArray(outgoingPayload?.items || outgoingPayload))
    } catch (_error) {
      // ignore in background
    }
  }, [])

  const fetchConversations = React.useCallback(async () => {
    setLoadingConversations(true)

    try {
      const payload = await conversationsApi.list({ per_page: 80 })
      const normalized = asConversationCollection(payload)
      const items = normalized.items

      setConversations(items)

      if (items.length === 0) {
        setActiveConversationId(null)
      } else {
        setActiveConversationId((previous) => {
          if (!previous) {
            return items[0].id
          }

          const exists = items.some((conversation) => Number(conversation.id) === Number(previous))
          return exists ? previous : items[0].id
        })
      }
    } catch (error) {
      const apiError = toApiError(error, 'Could not fetch conversations')
      notify(apiError.message)
    } finally {
      setLoadingConversations(false)
    }
  }, [notify])

  const fetchConversationMessages = React.useCallback(async (conversationId, append = false) => {
    if (!conversationId) {
      return
    }

    setLoadingMessages(true)

    try {
      const key = String(conversationId)
      const current = messagesByConversationRef.current[key] || { items: [] }
      const currentItems = current.items || []

      const params = { limit: MESSAGE_PAGE_SIZE }

      if (append) {
        const numericIds = currentItems
          .map((message) => Number(message.id))
          .filter((id) => Number.isFinite(id))

        if (numericIds.length > 0) {
          params.cursor_id = Math.min(...numericIds)
        }
      }

      const payload = await messagesApi.list(conversationId, params)
      const incoming = toArray(payload)

      setMessagesByConversation((previous) => {
        const currentState = previous[key] || { items: [], hasMore: false }
        const merged = append
          ? uniqueById([...currentState.items, ...incoming])
          : uniqueById(incoming)

        return {
          ...previous,
          [key]: {
            items: merged,
            hasMore: incoming.length >= MESSAGE_PAGE_SIZE,
          },
        }
      })
    } catch (error) {
      const apiError = toApiError(error, 'Could not fetch messages')
      notify(apiError.message)
    } finally {
      setLoadingMessages(false)
    }
  }, [notify])

  const fetchParticipants = React.useCallback(async (conversationId) => {
    if (!conversationId) {
      return
    }

    setLoadingParticipants(true)

    try {
      const payload = await conversationsApi.listParticipants(conversationId)
      const participants = toArray(payload)

      setParticipantsByConversation((previous) => ({
        ...previous,
        [String(conversationId)]: participants,
      }))
    } catch (error) {
      const apiError = toApiError(error, 'Could not fetch participants')
      notify(apiError.message)
    } finally {
      setLoadingParticipants(false)
    }
  }, [notify])

  const upsertMessage = React.useCallback((conversationId, patch) => {
    setMessagesByConversation((previous) => {
      const key = String(conversationId)
      const current = previous[key] || { items: [], hasMore: false }
      const nextItems = uniqueById([
        patch,
        ...current.items.filter((item) => String(item.id) !== String(patch.id)),
      ])

      return {
        ...previous,
        [key]: {
          ...current,
          items: nextItems,
        },
      }
    })
  }, [])

  const patchMessage = React.useCallback((conversationId, messageId, patch) => {
    setMessagesByConversation((previous) => {
      const key = String(conversationId)
      const current = previous[key]
      if (!current) {
        return previous
      }

      return {
        ...previous,
        [key]: {
          ...current,
          items: current.items.map((item) => {
            if (String(item.id) !== String(messageId)) {
              return item
            }

            return {
              ...item,
              ...patch,
            }
          }),
        },
      }
    })
  }, [])

  React.useEffect(() => {
    fetchConversations()
    fetchFriendData()
  }, [fetchConversations, fetchFriendData])

  React.useEffect(() => {
    if (!activeConversationId) {
      return
    }

    fetchConversationMessages(activeConversationId, false)
    fetchParticipants(activeConversationId)
    setTypingUsers({})
  }, [activeConversationId, fetchConversationMessages, fetchParticipants])

  React.useEffect(() => {
    const keyword = searchKeyword.trim()
    if (!keyword) {
      setSearchResults([])
      setSearchLoading(false)
      if (searchDebounceRef.current) {
        clearTimeout(searchDebounceRef.current)
      }
      return
    }

    const digitsOnly = keyword.replace(/\D/g, '')
    const isPhoneLikeSearch = digitsOnly.length > 0 && digitsOnly.length === keyword.length
    if (isPhoneLikeSearch && digitsOnly.length < 10) {
      setSearchResults([])
      setSearchLoading(false)
      if (searchDebounceRef.current) {
        clearTimeout(searchDebounceRef.current)
      }
      return
    }

    if (searchDebounceRef.current) {
      clearTimeout(searchDebounceRef.current)
    }

    setSearchLoading(true)
    searchDebounceRef.current = setTimeout(async () => {
      try {
        const payload = await usersApi.search({ q: keyword, per_page: 20 })
        setSearchResults(toArray(payload?.items || payload))
      } catch (error) {
        const apiError = toApiError(error, 'Could not search users')
        notify(apiError.message)
      } finally {
        setSearchLoading(false)
      }
    }, 280)

    return () => {
      if (searchDebounceRef.current) {
        clearTimeout(searchDebounceRef.current)
      }
    }
  }, [notify, searchKeyword])

  React.useEffect(() => {
    const ids = conversations.map((conversation) => conversation.id)
    if (ids.length === 0 || !user?.id || !token) {
      return undefined
    }

    const leaveCallbacks = ids.map((conversationId) => {
      return subscribeConversationChannel(conversationId, {
        onMessageCreated: (payload) => {
          if (!payload?.conversation_id || !payload?.message) {
            return
          }

          upsertMessage(payload.conversation_id, payload.message)
          fetchConversations()
        },
        onMessageUpdated: (payload) => {
          if (!payload?.conversation_id || !payload?.message) {
            return
          }

          patchMessage(payload.conversation_id, payload.message.id, payload.message)
          fetchConversations()
        },
        onMessageDeletedForEveryone: (payload) => {
          if (!payload?.conversation_id || !payload?.message_id) {
            return
          }

          patchMessage(payload.conversation_id, payload.message_id, {
            deleted_for_everyone_at: payload.deleted_for_everyone_at,
            content: null,
            content_json: null,
          })
          fetchConversations()
        },
        onReactionChanged: (payload) => {
          if (!payload?.conversation_id || !payload?.message_id) {
            return
          }

          patchMessage(payload.conversation_id, payload.message_id, {
            reaction_summary: payload.summary || [],
          })
        },
        onReadUpdated: (payload) => {
          if (!payload?.conversation_id || !payload?.user_id) {
            return
          }

          setParticipantsByConversation((previous) => {
            const key = String(payload.conversation_id)
            const current = previous[key]
            if (!current) {
              return previous
            }

            return {
              ...previous,
              [key]: current.map((participant) => {
                if (Number(participant?.user?.id) !== Number(payload.user_id)) {
                  return participant
                }

                return {
                  ...participant,
                  last_read_message_id: payload.last_read_message_id,
                  last_read_at: payload.last_read_at,
                  unread_count_cache: payload.unread_count_cache,
                }
              }),
            }
          })

          fetchConversations()
        },
        onDeliveredUpdated: (payload) => {
          if (!payload?.conversation_id || !payload?.user_id) {
            return
          }

          setParticipantsByConversation((previous) => {
            const key = String(payload.conversation_id)
            const current = previous[key]
            if (!current) {
              return previous
            }

            return {
              ...previous,
              [key]: current.map((participant) => {
                if (Number(participant?.user?.id) !== Number(payload.user_id)) {
                  return participant
                }

                return {
                  ...participant,
                  last_delivered_message_id: payload.last_delivered_message_id,
                  last_delivered_at: payload.last_delivered_at,
                }
              }),
            }
          })
        },
        onTypingUpdated: (payload) => {
          if (!payload?.conversation_id || !payload?.user || Number(payload.user.id) === Number(user.id)) {
            return
          }

          if (Number(payload.conversation_id) !== Number(activeConversationIdRef.current)) {
            return
          }

          const actorId = String(payload.user.id)

          setTypingUsers((previous) => {
            if (!payload.is_typing) {
              const next = { ...previous }
              delete next[actorId]
              return next
            }

            return {
              ...previous,
              [actorId]: payload.user,
            }
          })

          if (remoteTypingTimeoutRef.current[actorId]) {
            clearTimeout(remoteTypingTimeoutRef.current[actorId])
          }

          remoteTypingTimeoutRef.current[actorId] = setTimeout(() => {
            setTypingUsers((previous) => {
              const next = { ...previous }
              delete next[actorId]
              return next
            })
          }, 2200)
        },
      }, token)
    })

    return () => {
      leaveCallbacks.forEach((leave) => leave())
    }
  }, [conversations, fetchConversations, patchMessage, token, upsertMessage, user?.id])

  React.useEffect(() => {
    if (!activeConversationId) {
      setPresenceUsers([])
      return undefined
    }

    return joinConversationPresence(activeConversationId, {
      onHere: (members) => setPresenceUsers(members || []),
      onJoining: (member) => setPresenceUsers((previous) => uniqueById([...(previous || []), member])),
      onLeaving: (member) => {
        setPresenceUsers((previous) => previous.filter((item) => Number(item.id) !== Number(member.id)))
      },
      onError: () => setPresenceUsers([]),
    }, token)
  }, [activeConversationId, token])

  React.useEffect(() => {
    if (!user?.id || !token) {
      return undefined
    }

    return subscribeUserChannel(user.id, {
      onFriendRequestReceived: () => fetchFriendData(),
      onFriendRequestAccepted: () => fetchFriendData(),
      onFriendRequestRejected: () => fetchFriendData(),
      onFriendRemoved: () => fetchFriendData(),
      onConversationSettingsUpdated: () => fetchConversations(),
    }, token)
  }, [fetchConversations, fetchFriendData, token, user?.id])

  React.useEffect(() => {
    if (!activeConversationId || !user?.id || !latestMessageId) {
      return
    }

    const key = String(activeConversationId)
    const marker = receiptsRef.current[key] || { delivered: null, read: null }

    if (marker.delivered !== latestMessageId) {
      marker.delivered = latestMessageId
      conversationsApi.markDelivered(activeConversationId, user.id, latestMessageId).catch(() => {})
    }

    if (marker.read !== latestMessageId) {
      marker.read = latestMessageId
      conversationsApi.markRead(activeConversationId, user.id, latestMessageId).catch(() => {})
    }

    receiptsRef.current[key] = marker
  }, [activeConversationId, latestMessageId, user?.id])

  React.useEffect(() => {
    return () => {
      if (searchDebounceRef.current) {
        clearTimeout(searchDebounceRef.current)
      }

      if (typingDebounceRef.current) {
        clearTimeout(typingDebounceRef.current)
      }

      if (typingStopRef.current) {
        clearTimeout(typingStopRef.current)
      }

      Object.values(remoteTypingTimeoutRef.current).forEach((timerId) => clearTimeout(timerId))
    }
  }, [])

  const setTypingStatus = React.useCallback(async (isTyping) => {
    if (!activeConversationId) {
      return
    }

    try {
      await conversationsApi.typing(activeConversationId, isTyping)
    } catch (_error) {
      // ignore typing errors
    }
  }, [activeConversationId])

  const signalTyping = React.useCallback(() => {
    if (!activeConversationId) {
      return
    }

    if (typingDebounceRef.current) {
      clearTimeout(typingDebounceRef.current)
    }
    if (typingStopRef.current) {
      clearTimeout(typingStopRef.current)
    }

    typingDebounceRef.current = setTimeout(() => {
      setTypingStatus(true)
    }, 220)

    typingStopRef.current = setTimeout(() => {
      setTypingStatus(false)
    }, 1500)
  }, [activeConversationId, setTypingStatus])

  const openDirectWithUser = React.useCallback(async (targetUserId) => {
    try {
      const conversation = await conversationsApi.createDirect(Number(targetUserId))
      setConversations((previous) => uniqueById([conversation, ...previous]))
      setActiveConversationId(conversation.id)
      notify('Direct conversation opened')
      fetchConversations()
    } catch (error) {
      const apiError = toApiError(error, 'Could not open direct conversation')
      notify(apiError.message)
    }
  }, [fetchConversations, notify])

  const handleSendFriendRequest = React.useCallback(async (targetUserId) => {
    try {
      await friendsApi.sendRequest({ target_user_id: targetUserId })
      notify('Friend request sent')
      fetchFriendData()
    } catch (error) {
      const apiError = toApiError(error, 'Could not send friend request')
      notify(apiError.message)
    }
  }, [fetchFriendData, notify])

  const handleAcceptFriendRequest = React.useCallback(async (requestId) => {
    try {
      setRequestProcessingId(requestId)
      await friendsApi.accept(requestId)
      notify('Friend request accepted')
      fetchFriendData()
    } catch (error) {
      const apiError = toApiError(error, 'Could not accept friend request')
      notify(apiError.message)
    } finally {
      setRequestProcessingId(null)
    }
  }, [fetchFriendData, notify])

  const handleRejectFriendRequest = React.useCallback(async (requestId) => {
    try {
      setRequestProcessingId(requestId)
      await friendsApi.reject(requestId)
      notify('Friend request rejected')
      fetchFriendData()
    } catch (error) {
      const apiError = toApiError(error, 'Could not reject friend request')
      notify(apiError.message)
    } finally {
      setRequestProcessingId(null)
    }
  }, [fetchFriendData, notify])

  const handleCancelFriendRequest = React.useCallback(async (requestId) => {
    try {
      setRequestProcessingId(requestId)
      await friendsApi.cancel(requestId)
      notify('Friend request cancelled')
      fetchFriendData()
    } catch (error) {
      const apiError = toApiError(error, 'Could not cancel friend request')
      notify(apiError.message)
    } finally {
      setRequestProcessingId(null)
    }
  }, [fetchFriendData, notify])

  const handleComposerTextChange = (value) => {
    setComposerText(value)
    signalTyping()
  }

  const handleAttachToComposer = () => {
    const fileName = window.prompt('Attachment file name', 'note.txt')
    if (!fileName) {
      return
    }

    const attachmentType = window.prompt('Attachment type: image|video|audio|file', 'file') || 'file'
    const storageKey = window.prompt('Storage key', `uploads/${Date.now()}-${fileName}`)
    if (!storageKey) {
      return
    }

    setComposerAttachment({
      attachment_type: attachmentType,
      file_name: fileName,
      file_ext: fileName.includes('.') ? fileName.split('.').pop() : null,
      mime_type: 'application/octet-stream',
      file_size: 1024,
      storage_provider: 'local',
      storage_bucket: null,
      storage_key: storageKey,
      file_url: null,
      thumbnail_url: null,
    })
  }

  const handleSendMessage = async () => {
    if (!activeConversationId) {
      return
    }

    const content = composerText.trim()
    if (!content && !composerAttachment) {
      return
    }

    setSending(true)

    const clientMessageId = createClientMessageId()
    const tempId = `temp-${clientMessageId}`

    const optimisticMessage = {
      id: tempId,
      conversation_id: activeConversationId,
      sender: {
        id: user?.id,
        display_name: user?.display_name,
        username: user?.username,
        avatar_url: user?.avatar_url,
      },
      sender_id: user?.id,
      client_message_id: clientMessageId,
      message_type: composerType,
      content,
      content_json: null,
      sent_at: new Date().toISOString(),
      message_status: 'sending',
      has_attachments: Boolean(composerAttachment),
      attachments: composerAttachment ? [composerAttachment] : [],
      reactions: [],
    }

    upsertMessage(activeConversationId, optimisticMessage)

    try {
      const message = await messagesApi.send(activeConversationId, {
        client_message_id: clientMessageId,
        message_type: composerType,
        content: content || null,
        attachments: composerAttachment ? [composerAttachment] : undefined,
      })

      setComposerText('')
      setComposerType('text')
      setComposerAttachment(null)
      setTypingStatus(false)

      setMessagesByConversation((previous) => {
        const key = String(activeConversationId)
        const current = previous[key] || { items: [], hasMore: false }
        const items = uniqueById([
          message,
          ...current.items.filter((item) => String(item.id) !== tempId),
        ])

        return {
          ...previous,
          [key]: {
            ...current,
            items,
          },
        }
      })

      fetchConversations()
    } catch (error) {
      setMessagesByConversation((previous) => {
        const key = String(activeConversationId)
        const current = previous[key]
        if (!current) {
          return previous
        }

        return {
          ...previous,
          [key]: {
            ...current,
            items: current.items.filter((item) => String(item.id) !== tempId),
          },
        }
      })

      const apiError = toApiError(error, 'Could not send message')
      notify(apiError.message)
    } finally {
      setSending(false)
    }
  }

  const handleLoadOlderMessages = () => {
    if (!activeConversationId || !currentMessagesState.hasMore || loadingMessages) {
      return
    }

    fetchConversationMessages(activeConversationId, true)
  }

  const handleEditMessage = async (message) => {
    const nextContent = window.prompt('Edit message content', message.content || '')
    if (nextContent === null) {
      return
    }

    try {
      const updated = await messagesApi.update(message.id, { content: nextContent })
      upsertMessage(activeConversationId, updated)
      notify('Message updated')
    } catch (error) {
      const apiError = toApiError(error, 'Could not update message')
      notify(apiError.message)
    }
  }

  const handleDeleteMessage = async (message) => {
    try {
      await messagesApi.destroy(message.id)
      patchMessage(activeConversationId, message.id, { sender_deleted_at: new Date().toISOString() })
      notify('Message deleted for your view')
    } catch (error) {
      const apiError = toApiError(error, 'Could not delete message')
      notify(apiError.message)
    }
  }

  const handleDeleteForEveryone = async (message) => {
    if (!window.confirm('Delete this message for everyone?')) {
      return
    }

    try {
      await messagesApi.deleteForEveryone(message.id)
      patchMessage(activeConversationId, message.id, {
        deleted_for_everyone_at: new Date().toISOString(),
        content: null,
        content_json: null,
      })
      notify('Message deleted for everyone')
    } catch (error) {
      const apiError = toApiError(error, 'Could not delete message for everyone')
      notify(apiError.message)
    }
  }

  const handleForwardMessage = async (message) => {
    const destinationId = Number(window.prompt('Forward to conversation id', ''))
    if (!Number.isFinite(destinationId)) {
      return
    }

    const content = window.prompt('Optional override content', '')

    try {
      await messagesApi.forward(message.id, {
        conversation_id: destinationId,
        content: content || undefined,
      })
      notify('Message forwarded')
    } catch (error) {
      const apiError = toApiError(error, 'Could not forward message')
      notify(apiError.message)
    }
  }

  const handleReactMessage = async (message, reactionCode) => {
    let code = reactionCode

    if (!code) {
      code = window.prompt('Reaction code', '❤️') || ''
    }

    if (!code) {
      return
    }

    try {
      await messagesApi.addReaction(message.id, code)
    } catch (error) {
      const apiError = toApiError(error, 'Could not react to message')
      notify(apiError.message)
    }
  }

  const handleUnreactMessage = async (message) => {
    const code = window.prompt('Reaction code to remove', '👍')
    if (!code) {
      return
    }

    try {
      await messagesApi.removeReaction(message.id, code)
    } catch (error) {
      const apiError = toApiError(error, 'Could not remove reaction')
      notify(apiError.message)
    }
  }

  const handleInspectReactions = async (message) => {
    try {
      const payload = await messagesApi.listReactions(message.id)
      const summary = toArray(payload?.summary || payload)
      if (!summary.length) {
        notify('No reactions')
        return
      }

      notify(summary.map((item) => `${item.reaction_code}: ${item.total}`).join(', '))
    } catch (error) {
      const apiError = toApiError(error, 'Could not fetch reactions')
      notify(apiError.message)
    }
  }

  const handleInspectMessage = async (message) => {
    try {
      const detail = await messagesApi.show(message.id)
      notify(`Message #${detail.id} • status: ${detail.message_status || 'unknown'}`)
    } catch (error) {
      const apiError = toApiError(error, 'Could not fetch message detail')
      notify(apiError.message)
    }
  }

  const handleAddAttachmentToMessage = async (message) => {
    const fileName = window.prompt('Attachment file name', 'file.txt')
    if (!fileName) {
      return
    }

    const storageKey = window.prompt('Storage key', `uploads/${Date.now()}-${fileName}`)
    if (!storageKey) {
      return
    }

    try {
      await messagesApi.addAttachment(message.id, {
        attachment_type: 'file',
        file_name: fileName,
        file_ext: fileName.includes('.') ? fileName.split('.').pop() : 'txt',
        mime_type: 'application/octet-stream',
        file_size: 1024,
        storage_provider: 'local',
        storage_bucket: null,
        storage_key: storageKey,
        file_url: null,
        thumbnail_url: null,
      })
      notify('Attachment added')
      fetchConversationMessages(activeConversationId, false)
    } catch (error) {
      const apiError = toApiError(error, 'Could not add attachment')
      notify(apiError.message)
    }
  }

  const handleRemoveAttachment = async (attachmentId) => {
    if (!attachmentId) {
      return
    }

    try {
      await messagesApi.removeAttachment(attachmentId)
      notify('Attachment removed')
      fetchConversationMessages(activeConversationId, false)
    } catch (error) {
      const apiError = toApiError(error, 'Could not remove attachment')
      notify(apiError.message)
    }
  }

  const handleArchiveToggle = async () => {
    if (!currentConversation) {
      return
    }

    try {
      if (currentConversation?.my_participant_settings?.is_archived) {
        await conversationsApi.unarchive(currentConversation.id)
      } else {
        await conversationsApi.archive(currentConversation.id)
      }

      fetchConversations()
    } catch (error) {
      const apiError = toApiError(error, 'Could not update archive status')
      notify(apiError.message)
    }
  }

  const handlePinToggle = async () => {
    if (!currentConversation || !user?.id) {
      return
    }

    try {
      if (currentConversation?.my_participant_settings?.is_pinned) {
        await conversationsApi.unpin(currentConversation.id, user.id)
      } else {
        await conversationsApi.pin(currentConversation.id, user.id)
      }

      fetchConversations()
    } catch (error) {
      const apiError = toApiError(error, 'Could not update pin status')
      notify(apiError.message)
    }
  }

  const handleMuteToggle = async () => {
    if (!currentConversation || !user?.id) {
      return
    }

    try {
      if (currentConversation?.my_participant_settings?.is_muted) {
        await conversationsApi.unmute(currentConversation.id, user.id)
      } else {
        const minutes = Number(window.prompt('Mute for minutes', '60'))
        if (!Number.isFinite(minutes) || minutes <= 0) {
          return
        }

        const mutedUntil = toMysqlDatetime(new Date(Date.now() + minutes * 60 * 1000))
        await conversationsApi.mute(currentConversation.id, user.id, mutedUntil)
      }

      fetchConversations()
    } catch (error) {
      const apiError = toApiError(error, 'Could not update mute status')
      notify(apiError.message)
    }
  }

  const handleHideToggle = async () => {
    if (!currentConversation || !user?.id) {
      return
    }

    try {
      if (currentConversation?.my_participant_settings?.is_hidden) {
        await conversationsApi.unhide(currentConversation.id, user.id)
      } else {
        await conversationsApi.hide(currentConversation.id, user.id)
      }

      fetchConversations()
    } catch (error) {
      const apiError = toApiError(error, 'Could not update hide status')
      notify(apiError.message)
    }
  }

  const handleUpdateGroup = async () => {
    if (!currentConversation) {
      return
    }

    const title = window.prompt('Group title', currentConversation.title || '')
    if (title === null) {
      return
    }

    const description = window.prompt('Description', currentConversation.description || '')

    try {
      await conversationsApi.update(currentConversation.id, {
        title,
        description,
      })
      notify('Conversation updated')
      fetchConversations()
    } catch (error) {
      const apiError = toApiError(error, 'Could not update conversation')
      notify(apiError.message)
    }
  }

  const handleDeleteConversation = async () => {
    if (!currentConversation) {
      return
    }

    if (!window.confirm('Delete this conversation?')) {
      return
    }

    try {
      await conversationsApi.destroy(currentConversation.id)
      notify('Conversation deleted')
      fetchConversations()
    } catch (error) {
      const apiError = toApiError(error, 'Could not delete conversation')
      notify(apiError.message)
    }
  }

  const handleAddParticipants = async () => {
    if (!activeConversationId || !newParticipantIdsInput.trim()) {
      return
    }

    const ids = newParticipantIdsInput
      .split(',')
      .map((value) => Number(value.trim()))
      .filter((value) => Number.isFinite(value))

    if (ids.length === 0) {
      notify('Invalid participant ids')
      return
    }

    try {
      await conversationsApi.addParticipants(activeConversationId, ids)
      setNewParticipantIdsInput('')
      notify('Participants added')
      fetchParticipants(activeConversationId)
      fetchConversations()
    } catch (error) {
      const apiError = toApiError(error, 'Could not add participants')
      notify(apiError.message)
    }
  }

  const handleRemoveParticipant = async (targetUserId) => {
    if (!activeConversationId) {
      return
    }

    try {
      await conversationsApi.removeParticipant(activeConversationId, targetUserId)
      notify('Participant removed')
      fetchParticipants(activeConversationId)
      fetchConversations()
    } catch (error) {
      const apiError = toApiError(error, 'Could not remove participant')
      notify(apiError.message)
    }
  }

  const handleUpdateParticipantRole = async (targetUserId) => {
    if (!activeConversationId) {
      return
    }

    const nextRole = window.prompt('Role: owner | admin | member', 'member')
    if (!nextRole) {
      return
    }

    try {
      await conversationsApi.updateParticipantRole(activeConversationId, targetUserId, nextRole)
      notify('Role updated')
      fetchParticipants(activeConversationId)
    } catch (error) {
      const apiError = toApiError(error, 'Could not update role')
      notify(apiError.message)
    }
  }

  const handleAvatarMenuSelect = async (action) => {
    if (action === 'logout') {
      await logout()
      window.location.href = '/login'
      return
    }

    if (action === 'profile') {
      try {
        if (user?.id) {
          const payload = await usersApi.show(user.id)
          if (payload?.user) {
            setProfileForm(buildProfileForm(payload.user))
          }
        }
      } catch (_error) {
        // ignore
      }
    }

    if (action === 'devices') {
      loadDevices()
    }

    if (action === 'friend-requests') {
      fetchFriendData()
    }

    setDrawerMode(action)
  }

  const handleSaveProfile = async () => {
    if (!user?.id) {
      return
    }

    setProfileSaving(true)

    try {
      const payload = {
        display_name: profileForm.display_name,
        username: profileForm.username || null,
        email: profileForm.email || null,
        phone_number: profileForm.phone_number || null,
        avatar_url: profileForm.avatar_url || null,
        bio: profileForm.bio || null,
        gender: profileForm.gender || null,
        birth_date: profileForm.birth_date || null,
        presence_status: profileForm.presence_status || 'offline',
      }

      if (profileForm.password.trim()) {
        payload.password = profileForm.password.trim()
      }

      const response = await usersApi.update(user.id, payload)
      if (response?.user) {
        setUser(response.user)
      }

      setProfileForm((previous) => ({ ...previous, password: '' }))
      notify('Profile updated')
    } catch (error) {
      const apiError = toApiError(error, 'Could not update profile')
      notify(apiError.message)
    } finally {
      setProfileSaving(false)
    }
  }

  const loadDevices = React.useCallback(async () => {
    setDevicesLoading(true)

    try {
      const payload = await devicesApi.list()
      setDevices(toArray(payload))
    } catch (error) {
      const apiError = toApiError(error, 'Could not fetch devices')
      notify(apiError.message)
    } finally {
      setDevicesLoading(false)
    }
  }, [notify])

  const handleSaveDevice = async () => {
    if (!deviceForm.device_uuid.trim()) {
      notify('device_uuid is required')
      return
    }

    setDeviceSaving(true)

    try {
      await devicesApi.create({
        ...deviceForm,
        is_active: true,
        touch_last_active: true,
      })
      notify('Device saved')
      setDeviceForm(buildDeviceForm())
      loadDevices()
    } catch (error) {
      const apiError = toApiError(error, 'Could not save device')
      notify(apiError.message)
    } finally {
      setDeviceSaving(false)
    }
  }

  const handleDeviceToggle = async (device) => {
    try {
      if (device.is_active) {
        await devicesApi.deactivate(device.id)
      } else {
        await devicesApi.activate(device.id)
      }
      loadDevices()
    } catch (error) {
      const apiError = toApiError(error, 'Could not update device')
      notify(apiError.message)
    }
  }

  const handleDeviceDelete = async (device) => {
    if (!window.confirm('Delete this device?')) {
      return
    }

    try {
      await devicesApi.destroy(device.id)
      loadDevices()
    } catch (error) {
      const apiError = toApiError(error, 'Could not delete device')
      notify(apiError.message)
    }
  }

  const renderDrawerContent = () => {
    if (drawerMode === 'profile') {
      return (
        <Stack spacing={1.1} sx={{ p: 2 }}>
          <Typography sx={{ fontWeight: 700, fontSize: 18 }}>Profile</Typography>
          <TextField size="small" label="Display name" value={profileForm.display_name} onChange={(event) => setProfileForm((previous) => ({ ...previous, display_name: event.target.value }))} />
          <TextField size="small" label="Username" value={profileForm.username} onChange={(event) => setProfileForm((previous) => ({ ...previous, username: event.target.value }))} />
          <TextField size="small" label="Email" value={profileForm.email} onChange={(event) => setProfileForm((previous) => ({ ...previous, email: event.target.value }))} />
          <TextField size="small" label="Phone" value={profileForm.phone_number} onChange={(event) => setProfileForm((previous) => ({ ...previous, phone_number: event.target.value }))} />
          <TextField size="small" label="Avatar URL" value={profileForm.avatar_url} onChange={(event) => setProfileForm((previous) => ({ ...previous, avatar_url: event.target.value }))} />
          <TextField size="small" label="Gender" value={profileForm.gender} onChange={(event) => setProfileForm((previous) => ({ ...previous, gender: event.target.value }))} />
          <TextField size="small" type="date" label="Birth date" InputLabelProps={{ shrink: true }} value={profileForm.birth_date || ''} onChange={(event) => setProfileForm((previous) => ({ ...previous, birth_date: event.target.value }))} />
          <TextField size="small" label="Presence" value={profileForm.presence_status} onChange={(event) => setProfileForm((previous) => ({ ...previous, presence_status: event.target.value }))} />
          <TextField size="small" type="password" label="New password" value={profileForm.password} onChange={(event) => setProfileForm((previous) => ({ ...previous, password: event.target.value }))} />
          <TextField size="small" multiline minRows={3} label="Bio" value={profileForm.bio} onChange={(event) => setProfileForm((previous) => ({ ...previous, bio: event.target.value }))} />
          <Stack direction="row" spacing={1}>
            <Button variant="contained" onClick={handleSaveProfile} disabled={profileSaving} sx={{ textTransform: 'none' }}>
              {profileSaving ? 'Saving...' : 'Save'}
            </Button>
            <Button variant="outlined" onClick={() => setProfileForm(buildProfileForm(user))} sx={{ textTransform: 'none' }}>
              Reset
            </Button>
          </Stack>
        </Stack>
      )
    }

    if (drawerMode === 'devices') {
      return (
        <Stack spacing={1.1} sx={{ p: 2 }}>
          <Typography sx={{ fontWeight: 700, fontSize: 18 }}>Devices</Typography>
          <Button
            variant="outlined"
            size="small"
            onClick={() => {
              const draft = buildDevicePayload()
              setDeviceForm({
                device_uuid: draft.device_uuid,
                device_type: draft.device_type,
                device_name: draft.device_name,
                push_token: '',
                app_version: draft.app_version,
                os_version: draft.os_version,
              })
            }}
            sx={{ alignSelf: 'flex-start', textTransform: 'none' }}
          >
            Use current browser
          </Button>
          <TextField size="small" label="device_uuid" value={deviceForm.device_uuid} onChange={(event) => setDeviceForm((previous) => ({ ...previous, device_uuid: event.target.value }))} />
          <TextField size="small" label="device_type" value={deviceForm.device_type} onChange={(event) => setDeviceForm((previous) => ({ ...previous, device_type: event.target.value }))} />
          <TextField size="small" label="device_name" value={deviceForm.device_name} onChange={(event) => setDeviceForm((previous) => ({ ...previous, device_name: event.target.value }))} />
          <TextField size="small" label="push_token" value={deviceForm.push_token} onChange={(event) => setDeviceForm((previous) => ({ ...previous, push_token: event.target.value }))} />
          <TextField size="small" label="app_version" value={deviceForm.app_version} onChange={(event) => setDeviceForm((previous) => ({ ...previous, app_version: event.target.value }))} />
          <TextField size="small" label="os_version" value={deviceForm.os_version} onChange={(event) => setDeviceForm((previous) => ({ ...previous, os_version: event.target.value }))} />
          <Stack direction="row" spacing={1}>
            <Button variant="contained" onClick={handleSaveDevice} disabled={deviceSaving} sx={{ textTransform: 'none' }}>
              {deviceSaving ? 'Saving...' : 'Save'}
            </Button>
            <Button variant="outlined" onClick={loadDevices} sx={{ textTransform: 'none' }}>
              Refresh
            </Button>
          </Stack>

          <Divider />

          {devicesLoading ? (
            <Stack alignItems="center" sx={{ py: 2 }}>
              <CircularProgress size={22} />
            </Stack>
          ) : null}

          <Stack spacing={0.8}>
            {devices.map((device) => (
              <Card key={device.id} variant="outlined">
                <CardContent sx={{ p: 1.1, '&:last-child': { pb: 1.1 } }}>
                  <Typography sx={{ fontWeight: 700, fontSize: 13 }}>{device.device_name || device.device_uuid}</Typography>
                  <Typography sx={{ fontSize: 12, color: '#64748b' }}>
                    {device.device_type} • active: {device.is_active ? 'true' : 'false'}
                  </Typography>
                  <Stack direction="row" spacing={0.8} sx={{ mt: 0.5 }}>
                    <Button size="small" onClick={() => handleDeviceToggle(device)} sx={{ textTransform: 'none' }}>
                      {device.is_active ? 'Deactivate' : 'Activate'}
                    </Button>
                    <Button size="small" color="error" onClick={() => handleDeviceDelete(device)} sx={{ textTransform: 'none' }}>
                      Delete
                    </Button>
                  </Stack>
                </CardContent>
              </Card>
            ))}

            {!devicesLoading && devices.length === 0 ? (
              <Typography sx={{ fontSize: 12.5, color: '#64748b' }}>No devices found.</Typography>
            ) : null}
          </Stack>
        </Stack>
      )
    }

    if (drawerMode === 'friend-requests') {
      return (
        <Stack spacing={1.2} sx={{ p: 2 }}>
          <Typography sx={{ fontWeight: 700, fontSize: 18 }}>Friend Requests</Typography>

          <Box>
            <Typography sx={{ fontWeight: 600, fontSize: 13.5, mb: 0.6 }}>Incoming</Typography>
            <Stack spacing={0.75}>
              {incomingRequests.map((request) => (
                <Card key={request.id} variant="outlined">
                  <CardContent sx={{ p: 1.1, '&:last-child': { pb: 1.1 } }}>
                    <Stack direction="row" alignItems="center" spacing={0.8}>
                      <Avatar src={request.requester?.avatar_url || undefined} sx={{ width: 30, height: 30 }}>
                        {(request.requester?.display_name || request.requester?.username || 'U').slice(0, 1)}
                      </Avatar>
                      <Box sx={{ minWidth: 0, flex: 1 }}>
                        <Typography noWrap sx={{ fontWeight: 600, fontSize: 13 }}>
                          {request.requester?.display_name || request.requester?.username || `User #${request.requester?.id}`}
                        </Typography>
                        <Typography sx={{ fontSize: 12, color: '#64748b' }}>status: {request.status}</Typography>
                      </Box>
                    </Stack>

                    {request.status === 'pending' ? (
                      <Stack direction="row" spacing={0.7} sx={{ mt: 0.7 }}>
                        <Button
                          size="small"
                          variant="contained"
                          onClick={() => handleAcceptFriendRequest(request.id)}
                          disabled={requestProcessingId === request.id}
                          sx={{ textTransform: 'none' }}
                        >
                          Accept
                        </Button>
                        <Button
                          size="small"
                          variant="outlined"
                          onClick={() => handleRejectFriendRequest(request.id)}
                          disabled={requestProcessingId === request.id}
                          sx={{ textTransform: 'none' }}
                        >
                          Reject
                        </Button>
                      </Stack>
                    ) : null}
                  </CardContent>
                </Card>
              ))}

              {incomingRequests.length === 0 ? (
                <Typography sx={{ fontSize: 12.5, color: '#64748b' }}>No incoming requests.</Typography>
              ) : null}
            </Stack>
          </Box>

          <Divider />

          <Box>
            <Typography sx={{ fontWeight: 600, fontSize: 13.5, mb: 0.6 }}>Outgoing</Typography>
            <Stack spacing={0.75}>
              {outgoingRequests.map((request) => (
                <Card key={request.id} variant="outlined">
                  <CardContent sx={{ p: 1.1, '&:last-child': { pb: 1.1 } }}>
                    <Stack direction="row" alignItems="center" spacing={0.8}>
                      <Avatar src={request.addressee?.avatar_url || undefined} sx={{ width: 30, height: 30 }}>
                        {(request.addressee?.display_name || request.addressee?.username || 'U').slice(0, 1)}
                      </Avatar>
                      <Box sx={{ minWidth: 0, flex: 1 }}>
                        <Typography noWrap sx={{ fontWeight: 600, fontSize: 13 }}>
                          {request.addressee?.display_name || request.addressee?.username || `User #${request.addressee?.id}`}
                        </Typography>
                        <Typography sx={{ fontSize: 12, color: '#64748b' }}>status: {request.status}</Typography>
                      </Box>
                    </Stack>

                    {request.status === 'pending' ? (
                      <Button
                        size="small"
                        variant="outlined"
                        sx={{ mt: 0.7, textTransform: 'none' }}
                        onClick={() => handleCancelFriendRequest(request.id)}
                        disabled={requestProcessingId === request.id}
                      >
                        Cancel
                      </Button>
                    ) : null}
                  </CardContent>
                </Card>
              ))}

              {outgoingRequests.length === 0 ? (
                <Typography sx={{ fontSize: 12.5, color: '#64748b' }}>No outgoing requests.</Typography>
              ) : null}
            </Stack>
          </Box>
        </Stack>
      )
    }

    return null
  }

  return (
    <>
      <Box
        sx={{
          minHeight: '100dvh',
          width: '100vw',
          display: 'flex',
          flexDirection: 'column',
          px: 0,
          py: 0,
          background: darkMode
            ? 'radial-gradient(circle at 20% 10%, #1d2028, #121318 48%, #0e0f13 100%)'
            : 'radial-gradient(circle at 22% 8%, #ffffff, #f0f3f8 50%, #e4e8ef 100%)',
        }}
      >
        <Stack spacing={1.2} sx={{ width: '100%', height: '100dvh', px: { xs: 1.1, md: 2 }, py: { xs: 1.1, md: 1.5 } }}>
          <Box
            component={motion.div}
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.35 }}
            sx={{
              width: '100%',
              flex: 1,
              minHeight: 0,
              borderRadius: { xs: '14px', md: '18px' },
              overflow: 'hidden',
              display: 'grid',
              gridTemplateColumns: { xs: '1fr', md: '390px 1fr' },
              border: darkMode ? '1px solid rgba(255,255,255,0.08)' : '1px solid rgba(255,255,255,0.8)',
              boxShadow: darkMode
                ? '0 28px 74px rgba(0,0,0,0.45), inset 0 1px 0 rgba(255,255,255,0.03)'
                : '0 26px 72px rgba(26,32,46,0.16), inset 0 1px 0 rgba(255,255,255,0.8)',
              backdropFilter: 'blur(14px)',
              bgcolor: darkMode ? 'rgba(16,18,24,0.74)' : 'rgba(255,255,255,0.74)',
            }}
          >
            <ChatListPanel
              darkMode={darkMode}
              user={user}
              conversations={conversations}
              activeConversationId={activeConversationId}
              onSelectConversation={setActiveConversationId}
              onRefreshConversations={fetchConversations}
              searchKeyword={searchKeyword}
              onSearchKeywordChange={setSearchKeyword}
              searchLoading={searchLoading}
              searchResults={searchResults}
              relationByUserId={relationByUserId}
              onOpenDirect={openDirectWithUser}
              onSendFriendRequest={handleSendFriendRequest}
              onAcceptFriendRequest={handleAcceptFriendRequest}
              onRejectFriendRequest={handleRejectFriendRequest}
              onCancelFriendRequest={handleCancelFriendRequest}
              onAvatarMenuSelect={handleAvatarMenuSelect}
            />

            <ConversationPanel
              darkMode={darkMode}
              conversation={currentConversation}
              messages={currentMessagesAsc}
              loadingMessages={loadingMessages}
              hasMore={currentMessagesState.hasMore}
              onLoadOlder={handleLoadOlderMessages}
              typingUsers={typingUsers}
              presenceUsers={presenceUsers}
              onEditMessage={handleEditMessage}
              onDeleteMessage={handleDeleteMessage}
              onDeleteForEveryone={handleDeleteForEveryone}
              onForwardMessage={handleForwardMessage}
              onReactMessage={handleReactMessage}
              onUnreactMessage={handleUnreactMessage}
              onInspectReactions={handleInspectReactions}
              onInspectMessage={handleInspectMessage}
              onAddAttachmentToMessage={handleAddAttachmentToMessage}
              onRemoveAttachment={handleRemoveAttachment}
              composerText={composerText}
              onComposerTextChange={handleComposerTextChange}
              onSendMessage={handleSendMessage}
              onAttachToComposer={handleAttachToComposer}
              composerAttachment={composerAttachment}
              onClearComposerAttachment={() => setComposerAttachment(null)}
              composerType={composerType}
              onComposerTypeChange={setComposerType}
              sending={sending}
              user={user}
              participants={currentParticipants}
              isOwner={isOwner}
              isOwnerOrAdmin={isOwnerOrAdmin}
              newParticipantIdsInput={newParticipantIdsInput}
              onNewParticipantIdsInputChange={setNewParticipantIdsInput}
              onAddParticipants={handleAddParticipants}
              onRemoveParticipant={handleRemoveParticipant}
              onUpdateParticipantRole={handleUpdateParticipantRole}
              onArchiveToggle={handleArchiveToggle}
              onPinToggle={handlePinToggle}
              onMuteToggle={handleMuteToggle}
              onHideToggle={handleHideToggle}
              onUpdateGroup={handleUpdateGroup}
              onDeleteConversation={handleDeleteConversation}
            />
          </Box>
        </Stack>
      </Box>

      <Drawer
        anchor="right"
        open={Boolean(drawerMode)}
        onClose={() => setDrawerMode(null)}
        PaperProps={{ sx: { width: { xs: '100%', sm: 380 }, bgcolor: '#f8fafc' } }}
      >
        <Stack direction="row" alignItems="center" justifyContent="space-between" sx={{ p: 1.4, borderBottom: '1px solid #e2e8f0' }}>
          <Typography sx={{ fontWeight: 700, color: '#0f172a' }}>
            {drawerMode === 'profile' ? 'Profile' : drawerMode === 'devices' ? 'Devices' : drawerMode === 'friend-requests' ? 'Friend Requests' : 'Menu'}
          </Typography>
          <Button size="small" onClick={() => setDrawerMode(null)} sx={{ textTransform: 'none' }}>
            Close
          </Button>
        </Stack>

        {renderDrawerContent()}
      </Drawer>

      {(loadingConversations || loadingParticipants) && !activeConversationId ? (
        <Stack
          sx={{
            position: 'fixed',
            inset: 0,
            display: 'grid',
            placeItems: 'center',
            pointerEvents: 'none',
          }}
        >
          <Stack alignItems="center" spacing={0.8}>
            <CircularProgress size={22} />
            <Typography sx={{ fontSize: 12.5, color: '#64748b' }}>Loading chat...</Typography>
          </Stack>
        </Stack>
      ) : null}
    </>
  )
}
