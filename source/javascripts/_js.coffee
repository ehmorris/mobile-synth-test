window.AudioContext = window.AudioContext || window.webkitAudioContext
context = new AudioContext()

gainNode = context.createGainNode()
gainNode.gain.value = 0
gainNode.connect(context.destination)

filter = context.createBiquadFilter()
filter.type = 0
filter.frequency.value = 440
filter.connect(gainNode)

oscillator = context.createOscillator() # Create sound source
oscillator.type = 1
oscillator.frequency.value = 400
oscillator.connect(filter) # Connect sound to output
oscillator.active = false

playSound = ->
  if !oscillator.active
    oscillator.noteOn(0)
  oscillator.active = true
  gainNode.gain.value = 0.5
  $('.fun').addClass 'active'
  false

stopSound = ->
  gainNode.gain.value = 0
  $('.fun').removeClass 'active'
  $('.press, .fun').attr 'style', ''
  false

shakeText = (x, y, z) ->
  $('.press').css {
    '-webkit-transform': "translate3D(#{x}px, #{y}px, #{x}px)"
  }

changeBackgroundColor = (x, y, z) ->
  x = Math.abs(Math.floor(x)) * 5
  y = Math.abs(Math.floor(y)) * 5
  z = Math.abs(Math.floor(z)) * 5
  $('.fun').css {
    'background-color': "rgb(#{x}, #{y}, #{z})"
  }

deviceMotionHandler = (eventData) ->
  a = eventData.accelerationIncludingGravity
  oscillator.frequency.value = 200 + a.x * 50

  if $('.fun').hasClass 'active'
    shakeText(a.x*5, -a.y*5, a.z*3)
    changeBackgroundColor(a.x, a.y, a.z)

devOrientHandler = (eventData) ->
  map_range = (value, low1, high1, low2, high2) ->
    low2 + (high2 - low2) * (value - low1) / (high1 - low1)

  # beta is the front-to-back tilt in degrees, where front is positive
  tiltFB = eventData.beta
  filterval = map_range(tiltFB, -90, 90, 10000, 0)
  filter.frequency.value = filterval

  # alpha is the compass direction the device is facing in degrees
  dir = eventData.alpha

$('.fun').bind 'touchstart', playSound
$('.fun').bind 'touchend', stopSound

window.addEventListener 'devicemotion', deviceMotionHandler, false
window.addEventListener 'deviceorientation', devOrientHandler, false
