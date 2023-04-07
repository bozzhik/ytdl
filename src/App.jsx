import React from 'react'

export default function App() {
  return (
    <div className="h-screen grid place-items-center">
      <div className="w-1/3 mx-auto">
        <h2 className="text-3xl mt-7 mb-3">YouTube Downloader</h2>
        <form>
          <input type="text" id="url" name="url" placeholder="Enter YouTube video URL" />
          <button type="submit" className="py-3 button">
            Download
          </button>
        </form>
      </div>
    </div>
  )
}
