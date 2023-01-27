// subscribe on server
var es = new EventSource("/api/actions/subscribe")

// receive server event for page reload
es.onmessage = (e) => {
  // check if is server close message
  if (e.data == "close") window.location.reload()
  // get url parameters
  let params = (new URL(window.location)).searchParams
  // get scroll position
  let pos = parseInt(e.data)
  // check scroll type
  if (pos == -1)
    // dont scroll, keep current preview page position
    pos = `${parseInt(window.scrollY)}px`
  else
    // check and set scroll position in percent
    pos = (isNan(pos) || pos < 0) ? 0 : (pos > 100) ? 100 : pos
  // set parameter 'scroll' for reload
  params.set("scroll", pos)
  // set url parameter and reload (if new params change url)
  window.location.search = params.toString()
};

// run script after page is loaded
addEventListener("load", (e) => {
  // get url parameters
  const params = (new URL(window.location)).searchParams
  // get 'scroll' parameter
  const scrollParam = params.get("scroll")
  // check 'scroll' parameter for pixel (234px) or percent (50) value
  const isPixel = (/^[0-9]+px$/.test(scrollParam)) ? true : false
  const isPercent = !isPixel
  // parse to int value
  let pos = parseInt(scrollParam)
  // check NaN or less 0
  pos = (isNaN(pos) || pos < 0) ? 0 : pos
  // if percent value
  if (isPercent) {
    // limit to max 100 %
    pos = (pos > 100) ? 100 : pos
    let documentHeight = document.documentElement.scrollHeight
    let windowHeight = window.innerHeight
    // calc relative scroll position to document height
    pos = Math.round((documentHeight * pos / 100.0) - (windowHeight / 2))
  }
  // scroll
  window.scrollTo(0, pos)
});
