// Scrolls to given position
function scrollToY(position) {
  // Checks if scrolling is needed
  if (position == -1) return;

  // check position
  const isPixel = /^[0-9]+px$/.test(position) ? true : false;
  const isPercent = !isPixel;
  // parse to int value
  let pos = parseInt(position);
  // check NaN or less 0
  pos = isNaN(pos) || pos < 0 ? 0 : pos;
  // if percent value
  if (isPercent) {
    // limit to max 100 %
    pos = pos > 100 ? 100 : pos;
    const documentHeight = document.documentElement.scrollHeight;
    const windowHeight = window.innerHeight;
    // calc relative scroll position to document height
    pos = Math.round((documentHeight * pos) / 100.0 - windowHeight / 2);
  }
  // scroll
  window.scrollTo(0, pos);
}

// -- EventSource -------------------------------------------------------------

// subscribe on server
const es = new EventSource("/api/actions/subscribe");

// receive server event for page reload
es.onmessage = (e) => {
  // check if is server close message
  if (e.data == "close") window.location.reload();
  // get url parameters
  const params = new URL(window.location).searchParams;
  // get scroll position
  let pos = parseInt(e.data);
  // check scroll type
  if (pos == -1) {
    // dont scroll, keep current preview page position
    pos = `${parseInt(window.scrollY)}px`;
  } else {
    // check and set scroll position in percent
    pos = isNaN(pos) || pos < 0 ? 0 : pos > 100 ? 100 : pos;
  }
  // set parameter 'scroll' for reload
  params.set("scroll", pos);
  // set url parameter and reload (if new params change url)
  window.location.search = params.toString();
};

// run script after page is loaded
addEventListener("load", (e) => {
  // get url parameters
  const params = new URL(window.location).searchParams;
  // get 'scroll' parameter
  const position = params.get("scroll");
  // scroll to position
  scrollToY(position);
});

// -- WebSocket ---------------------------------------------------------------

const ws = new WebSocket("ws://localhost:443/");

ws.onmessage = (event) => {
  let message;
  try {
    message = JSON.parse(event.data);
  } catch (e) {
    return;
  }

  // replace body content
  document.body.outerHTML = message.content;

  // execute highlighting script for code blocks again
  let newScript = document.createElement("script");
  newScript.src =
    "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.18.3/highlight.min.js";
  document.body.appendChild(newScript);
  newScript = document.createElement("script");
  newScript.innerHTML =
    // "hljs.initHighlighting.called = false ;if (!hljs.initHighlighting.called) { hljs.initHighlighting.called = true ;[].slice.call(document.querySelectorAll('pre.highlight > code[data-lang]')).forEach(function (el) { hljs.highlightBlock(el) }) } ";
    "[].slice.call(document.querySelectorAll('pre.highlight > code[data-lang]')).forEach(function (el) { hljs.highlightBlock(el) })";
  document.body.appendChild(newScript);

  // NOTE: reexecute all scripts in body
  // // todo: add  extra "hljs.initHighlighting.called = false"
  // let scripts = Array.prototype.slice.call(
  //   document.body.getElementsByTagName("script"),
  // );
  // scripts.forEach(function (script) {
  //   let newScript = document.createElement("script");
  //   if (script.src != "") newScript.src = script.src;
  //   else newScript.innerHTML = script.innerHTML;
  //   document.body.appendChild(newScript);
  // });

  // scroll to position
  scrollToY(message.position);
};

ws.onopen = () => {
  console.log("WebSocket: Connected");
};

ws.onclose = () => {
  console.log("WebSocket: Disconnected");
};

ws.onerror = function () {
  console.error(`WebSocket: Lost connection. Reason: ${error.message}`);
  ws.close();
};
