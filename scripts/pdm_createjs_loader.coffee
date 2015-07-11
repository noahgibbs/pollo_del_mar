PDM.CreatejsDisplay.loader = {}
loader = window.PDM.CreatejsDisplay.loader
loader.handlers = []

loader.init = () ->
  return if loader.initialized
  # TODO: experiment with LoadQueue's CORS settings on constructor
  # TODO: for lots of loading, see if multi-connection XHR is better/faster
  loader.queue = new createjs.LoadQueue(false)  # False to recommend tag (DOM) loading rather than XHR
  loader.queue.addEventListener "complete", loader.imagesLoaded
  loader.initialized = true

loader.addHandler = (handler) ->
  loader.handlers.push handler

loader.removeHandler = (handler) ->
  index = $.inArray(handler, loader.handlers)
  loader.handlers.splice(index, 1) if index

loader.imagesLoaded = () ->
  handler() for handler in loader.handlers

loader.addImages = (images...) ->
  loader.init()
  for image in images
    if image.length?
      loader.queue.loadFile(img) for img in image
    else
      loader.queue.loadFile(image)
