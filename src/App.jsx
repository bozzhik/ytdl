import {useCallback, useState} from 'react'

export default function App() {
  const [buttonColor, setButtonColor] = useState('')

  const handleClick = useCallback(() => {
    console.log('Button clicked!')
    setButtonColor('#1095c1')
    setTimeout(() => {
      setButtonColor('')
    }, 1500)
  }, [])

  return (
    <div className="h-screen grid place-items-center">
      <div className="w-1/3 mx-auto">
        <h2 className="text-3xl mb-4">YouTube Downloader</h2>
        <form>
          <label htmlFor="url">Enter YouTube video URL:</label>
          <input type="text" id="url" name="url" placeholder="Enter YouTube video URL" />
          <button id="button" type="submit" role="button" className="py-3 button" onClick={handleClick} style={{backgroundColor: buttonColor}}>
            Download
          </button>
        </form>
      </div>
    </div>
  )
}
