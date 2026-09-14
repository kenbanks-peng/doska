import { useEffect, useState, type ReactNode } from "react"
import { ThemeCtx, type Theme } from "./theme-context"

const DARK_QUERY = "(prefers-color-scheme: dark)"

function isTheme(value: string | null): value is Theme {
  return value === "dark" || value === "light"
}

function systemTheme(): Theme {
  return window.matchMedia(DARK_QUERY).matches ? "dark" : "light"
}

export function ThemeProvider({ children }: { children: ReactNode }) {
  const [theme, setThemeState] = useState<Theme>(() => {
    const stored = localStorage.getItem("theme")
    return isTheme(stored) ? stored : systemTheme()
  })

  useEffect(() => {
    const query = window.matchMedia(DARK_QUERY)
    const onChange = () => {
      localStorage.removeItem("theme")
      setThemeState(systemTheme())
    }
    query.addEventListener("change", onChange)
    return () => query.removeEventListener("change", onChange)
  }, [])

  useEffect(() => {
    document.documentElement.classList.remove("light", "dark")
    document.documentElement.classList.add(theme)
  }, [theme])

  const setTheme = (next: Theme) => {
    localStorage.setItem("theme", next)
    setThemeState(next)
  }

  return (
    <ThemeCtx.Provider value={{ theme, setTheme }}>
      {children}
    </ThemeCtx.Provider>
  )
}
