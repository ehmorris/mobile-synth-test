window.AudioContext = window.AudioContext || window.webkitAudioContext
context = new AudioContext()

oscillator = context.createOscillator() # Create sound source
oscillator.type = 1 # Square wave
oscillator.frequency.value = 400
filter = context.createBiquadFilter()

gainNode = context.createGainNode()
gainNode.gain.value = 0
filter.type = 0
filter.frequency.value = 440

oscillator.connect(filter) # Connect sound to output
filter.connect(gainNode)
gainNode.connect(context.destination)
oscillator.active = false

playSound = (e) ->
  if !oscillator.active
    oscillator.noteOn(0)
  oscillator.active = true
  gainNode.gain.value = 0.5
  $('.fun').addClass 'active'
  false

stopSound = (e) ->
  gainNode.gain.value = 0
  $('.fun').removeClass 'active'
  false

deviceMotionHandler = (eventData) ->
  info = '[X, Y, Z]'
  xyz = '[X, Y, Z]'

  # Grab the acceleration from the results
  acceleration = eventData.acceleration
  info = xyz.replace('X', acceleration.x)
  info = info.replace('Y', acceleration.y)
  info = info.replace('Z', acceleration.z)

  # Grab the acceleration including gravity from the results
  acceleration = eventData.accelerationIncludingGravity
  info = xyz.replace('X', acceleration.x)
  info = info.replace('Y', acceleration.y)
  info = info.replace('Z', acceleration.z)

  # Grab the rotation rate from the results
  rotation = eventData.rotationRate
  info = xyz.replace('X', rotation.alpha)
  info = info.replace('Y', rotation.beta)
  info = info.replace('Z', rotation.gamma)

  # Grab the refresh interval from the results
  info = eventData.interval

  accelControl = acceleration.x
  oscillator.frequency.value = 200 + accelControl * 50

devOrientHandler = (eventData) ->
  map_range = (value, low1, high1, low2, high2) ->
    low2 + (high2 - low2) * (value - low1) / (high1 - low1)

  # gamma is the left-to-right tilt in degrees, where right is positive
  tiltLR = eventData.gamma

  # beta is the front-to-back tilt in degrees, where front is positive
  tiltFB = eventData.beta
  filterval = map_range(tiltFB, -90, 90, 10000, 0)
  filter.frequency.value = filterval

  # alpha is the compass direction the device is facing in degrees
  dir = eventData.alpha

$('.fun').bind('touchstart', playSound)
$('.fun').bind('touchend', stopSound)

window.addEventListener 'devicemotion', deviceMotionHandler, false
window.addEventListener 'deviceorientation', devOrientHandler, false
