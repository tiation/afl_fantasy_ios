import * as React from "react"
import { toast as sonnerToast } from "sonner"
import {
  CheckCircleIcon,
  XCircleIcon,
  ExclamationTriangleIcon,
  InformationCircleIcon,
  ArrowsRightLeftIcon,
  UserIcon
} from '@heroicons/react/24/outline'

export type ToastVariant = "default" | "destructive" | "success" | "warning" | "info"

export interface ToastProps {
  id: string
  title?: React.ReactNode
  description?: React.ReactNode
  action?: React.ReactElement
  variant?: ToastVariant
}

const actionTypes = {
  ADD_TOAST: "ADD_TOAST",
  UPDATE_TOAST: "UPDATE_TOAST", 
  DISMISS_TOAST: "DISMISS_TOAST",
  REMOVE_TOAST: "REMOVE_TOAST",
} as const

type ActionType = typeof actionTypes[keyof typeof actionTypes]

type Action =
  | {
      type: typeof actionTypes.ADD_TOAST
      toast: ToastProps
    }
  | {
      type: typeof actionTypes.UPDATE_TOAST
      toast: Partial<ToastProps>
    }
  | {
      type: typeof actionTypes.DISMISS_TOAST
      toastId?: ToastProps["id"]
    }
  | {
      type: typeof actionTypes.REMOVE_TOAST
      toastId?: ToastProps["id"]
    }

interface State {
  toasts: ToastProps[]
}

const toastTimeouts = new Map<string, ReturnType<typeof setTimeout>>()

const addToRemoveQueue = (toastId: string) => {
  if (toastTimeouts.has(toastId)) {
    return
  }

  const timeout = setTimeout(() => {
    toastTimeouts.delete(toastId)
    dispatch({
      type: "REMOVE_TOAST",
      toastId: toastId,
    })
  }, 1000000)

  toastTimeouts.set(toastId, timeout)
}

export const reducer = (state: State, action: Action): State => {
  switch (action.type) {
    case "ADD_TOAST":
      return {
        ...state,
        toasts: [action.toast, ...state.toasts].slice(0, 1),
      }

    case "UPDATE_TOAST":
      return {
        ...state,
        toasts: state.toasts.map((t) =>
          t.id === action.toast.id ? { ...t, ...action.toast } : t
        ),
      }

    case "DISMISS_TOAST": {
      const { toastId } = action

      if (toastId) {
        addToRemoveQueue(toastId)
      } else {
        state.toasts.forEach((toast) => {
          addToRemoveQueue(toast.id)
        })
      }

      return {
        ...state,
        toasts: state.toasts.map((t) =>
          t.id === toastId || toastId === undefined
            ? {
                ...t,
                open: false,
              }
            : t
        ),
      }
    }
    case "REMOVE_TOAST":
      if (action.toastId === undefined) {
        return {
          ...state,
          toasts: [],
        }
      }
      return {
        ...state,
        toasts: state.toasts.filter((t) => t.id !== action.toastId),
      }
  }
}

const listeners: Array<(state: State) => void> = []

let memoryState: State = { toasts: [] }

function dispatch(action: Action) {
  memoryState = reducer(memoryState, action)
  listeners.forEach((listener) => {
    listener(memoryState)
  })
}

type Toast = Omit<ToastProps, "id">

function toast({ ...props }: Toast) {
  const id = genId()

  const update = (props: ToastProps) =>
    dispatch({
      type: "UPDATE_TOAST",
      toast: { ...props, id },
    })
  const dismiss = () => dispatch({ type: "DISMISS_TOAST", toastId: id })

  dispatch({
    type: "ADD_TOAST",
    toast: {
      ...props,
      id,
      open: true,
      onOpenChange: (open) => {
        if (!open) dismiss()
      },
    },
  })

  return {
    id: id,
    dismiss,
    update,
  }
}

function useToast() {
  const [state, setState] = React.useState<State>(memoryState)

  React.useEffect(() => {
    listeners.push(setState)
    return () => {
      const index = listeners.indexOf(setState)
      if (index > -1) {
        listeners.splice(index, 1)
      }
    }
  }, [state])

  return {
    ...state,
    toast,
    dismiss: (toastId?: string) => dispatch({ type: "DISMISS_TOAST", toastId }),
  }
}

function genId() {
  return Math.random().toString(36).substr(2, 9)
}

// AFL Fantasy specific toast helpers
export function useAFLToasts() {
  const { toast } = useToast()
  
  // Trade-specific toasts with optimistic UI
  const tradeSuccess = React.useCallback((playerIn: string, playerOut: string) => {
    return toast({
      title: "Trade Completed!",
      description: (
        <div className="flex items-center space-x-2">
          <ArrowsRightLeftIcon className="h-4 w-4 text-green-500" />
          <span>{playerOut} → {playerIn}</span>
        </div>
      ),
      variant: "success"
    })
  }, [toast])

  const tradeOptimistic = React.useCallback((playerIn: string, playerOut: string) => {
    return toast({
      title: "Processing Trade...",
      description: (
        <div className="flex items-center space-x-2">
          <div className="animate-spin h-4 w-4 border-2 border-afl-primary border-t-transparent rounded-full" />
          <span>Trading {playerOut} for {playerIn}</span>
        </div>
      ),
      variant: "default"
    })
  }, [toast])

  const tradeError = React.useCallback((message: string) => {
    return toast({
      title: "Trade Failed",
      description: message,
      variant: "destructive"
    })
  }, [toast])

  // Captain selection
  const captainSet = React.useCallback((playerName: string) => {
    return toast({
      title: "Captain Set!",
      description: (
        <div className="flex items-center space-x-2">
          <UserIcon className="h-4 w-4 text-yellow-500" />
          <span>{playerName} is now your captain</span>
        </div>
      ),
      variant: "success"
    })
  }, [toast])

  // Team value updates
  const teamValueUpdated = React.useCallback((oldValue: string, newValue: string) => {
    const isIncrease = parseFloat(newValue.replace('$', '').replace('M', '')) > 
                      parseFloat(oldValue.replace('$', '').replace('M', ''))
    
    return toast({
      title: "Team Value Updated",
      description: (
        <div className="flex items-center space-x-2">
          <span className={isIncrease ? 'text-green-500' : 'text-red-500'}>
            {oldValue} → {newValue}
          </span>
        </div>
      ),
      variant: isIncrease ? "success" : "warning"
    })
  }, [toast])

  // Generic success/error toasts with AFL branding
  const success = React.useCallback((title: string, message?: string) => {
    return toast({
      title,
      description: message,
      variant: "success"
    })
  }, [toast])

  const error = React.useCallback((title: string, message?: string) => {
    return toast({
      title,
      description: message,
      variant: "destructive"
    })
  }, [toast])

  const info = React.useCallback((title: string, message?: string) => {
    return toast({
      title,
      description: message,
      variant: "info"
    })
  }, [toast])

  const warning = React.useCallback((title: string, message?: string) => {
    return toast({
      title,
      description: message,
      variant: "warning"
    })
  }, [toast])

  // Promise-based toast for async operations
  const promise = React.useCallback(async <T,>(
    promise: Promise<T>,
    {
      loading = "Loading...",
      success: successMsg = "Success!",
      error: errorMsg = "Something went wrong"
    }: {
      loading?: string
      success?: string | ((data: T) => string)
      error?: string | ((error: any) => string)
    } = {}
  ): Promise<T> => {
    const loadingToast = toast({
      title: loading,
      variant: "default"
    })

    try {
      const result = await promise
      loadingToast.dismiss()
      
      const successMessage = typeof successMsg === 'function' ? successMsg(result) : successMsg
      toast({
        title: successMessage,
        variant: "success"
      })
      
      return result
    } catch (err) {
      loadingToast.dismiss()
      
      const errorMessage = typeof errorMsg === 'function' ? errorMsg(err) : errorMsg
      toast({
        title: errorMessage,
        variant: "destructive"
      })
      
      throw err
    }
  }, [toast])

  return {
    // AFL-specific
    tradeSuccess,
    tradeOptimistic,
    tradeError,
    captainSet,
    teamValueUpdated,
    
    // Generic
    success,
    error,
    info,
    warning,
    promise,
    
    // Raw toast function
    toast
  }
}

export { useToast, toast }
