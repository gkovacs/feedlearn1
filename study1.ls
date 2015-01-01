root = exports ? this

{first-non-null, getUrlParameters, getvar, setvar, get-user-events, get-condition, forcehttps, updatecookies, updatecookiesandevents, getFBAppId} = root # commonlib.ls
{post-json, post-start-event, addlog, addlogfblogin} = root # logging_client.ls

root.skip-prereqs = false

readable-test-names = {
  pretest1: 'Pre-Test for Week 1'
  pretest2: 'Pre-Test for Week 2'
  pretest3: 'Pre-Test for Week 3'
  posttest1: 'Post-Test for Week 1'
  posttest2: 'Post-Test for Week 2'
  posttest3: 'Post-Test for Week 3'
}

alert-prereqs = (plist) ->
  #if window.location.href == "http://localhost:5000/study1"
  #  return
  if root.skip-prereqs
    return true
  for x in plist
    if not root.completed-parts[x]?
      testname = x
      if readable-test-names[x]?
        testname = readable-test-names[x]
      toastr.error 'You need to take the following test first: ' + testname
      return false
  return true

export consent-agreed = ->
  $('#collapseOne').data 'allowcollapse', true
  $('#collapseOne').collapse('hide')
  root.completed-parts.consentagreed = Date.now()
  open-part-that-needs-doing()
  #forcecollapse $('#collapseOne')
  #$('#collapseTwo').collapse('show')
  show-consent-agreed()
  post-start-event 'consentagreed'

export open-pretest1 = ->
  #if not alert-prereqs ['consentagreed']
  #  return
  window.open('matching?vocab=japanese1&type=pretest')

export open-posttest1 = ->
  if not alert-prereqs ['pretest1']
    return
  testtime = root.completed-parts['pretest1'] + 1000*3600*24*7
  if Date.now() < testtime
    toastr.error 'Please wait until ' + moment(testtime).format('llll') + ' to take the post-test for week 1 vocabulary'
    return
  window.open('matching?vocab=japanese1&type=posttest')

export open-pretest2 = ->
  if not alert-prereqs ['posttest1']
    return
  window.open('matching?vocab=japanese2&type=pretest')

export open-posttest2 = ->
  if not alert-prereqs ['pretest2']
    return
  testtime = root.completed-parts['pretest2'] + 1000*3600*24*7
  if Date.now() < testtime
    toastr.error 'Please wait until ' + moment(testtime).format('llll') + ' to take the post-test for week 2 vocabulary'
    return
  window.open('matching?vocab=japanese2&type=posttest')

export open-pretest3 = ->
  if not alert-prereqs ['posttest2']
    return
  window.open('matching?vocab=japanese3&type=pretest')

export open-posttest3 = ->
  if not alert-prereqs ['pretest3']
    return
  testtime = root.completed-parts['pretest3'] + 1000*3600*24*7
  if Date.now() < testtime
    toastr.error 'Please wait until ' + moment(testtime).format('llll') + ' to take the post-test for week 3 vocabulary'
    return
  window.open('matching?vocab=japanese3&type=posttest')

export open-survey = ->
  target = 'https://stanforduniversity.qualtrics.com/SE/?SID=SV_6nCpYFc4aBE0Z81&' + $.param({
    fbname: getvar('fbname')
    fburl: getvar('fburl')
    fullname: get-user-name()
    condition: getvar('condition')
    lang: getvar('lang')
  })
  window.open target

export chromeExtensionInstallFinished = ->
  $('#extensioninstalledcheck').css 'visibility', 'visible'
  $('#extensioninstalleddisplay').css('color', 'green').text 'FeedLearn Chrome Extension has been installed!'
  $('#extensioninstallbutton').attr 'disabled', true
  $('#collapseThree').data 'allowcollapse', true
  $('#collapseThree').collapse('hide')
  open-part-that-needs-doing()

export install-chrome-extension = ->
  #window.open('https://chrome.google.com/webstore/detail/feed-learn/ebmjdfhplinmlajmdcmhkikideknlgkf')
  #chrome.webstore.install('https://chrome.google.com/webstore/detail/ebmjdfhplinmlajmdcmhkikideknlgkf')
  if chrome? and chrome.webstore? and chrome.webstore.install?
    chrome.webstore.install(
      url='https://chrome.google.com/webstore/detail/ebmjdfhplinmlajmdcmhkikideknlgkf',
      successCallback=chromeExtensionInstallFinished
    )
  else
    window.open('https://chrome.google.com/webstore/detail/feed-learn/ebmjdfhplinmlajmdcmhkikideknlgkf')

export start-week1 = ->
  if not alert-prereqs ['pretest1']
    return
  config-week1()
  $('#startweek1button').attr 'disabled', true
  post-start-event 'week1startstudy'

export config-week1 = ->
  setvar 'fullname', root.fullname
  setvar 'scriptformat', 'show romanized only'
  setvar 'lang', 'japanese1'
  #setvar 'format', 'link'
  setvar 'format', root.studyorder[0]

export start-week2 = ->
  if not alert-prereqs ['pretest2']
    return
  config-week2()
  $('#startweek2button').attr 'disabled', true
  post-start-event 'week2startstudy'

export config-week2 = ->
  setvar 'fullname', root.fullname
  setvar 'scriptformat', 'show romanized only'
  setvar 'lang', 'japanese2'
  #setvar 'format', 'interactive'
  setvar 'format', root.studyorder[1]

export start-week3 = ->
  if not alert-prereqs ['pretest3']
    return
  config-week3()
  $('#startweek3button').attr 'disabled', true
  post-start-event 'week3startstudy'

export config-week3 = ->
  setvar 'fullname', root.fullname
  setvar 'scriptformat', 'show romanized only'
  setvar 'lang', 'japanese3'
  #setvar 'format', 'none'
  setvar 'format', root.studyorder[2]

export config-week = (num) ->
  switch num
  | 1 => config-week1()
  | 2 => config-week2()
  | 3 => config-week3()

export full-name-submitted = ->
  newfullname = $('#fullnameinput').val().trim()
  if newfullname.length > 0
    root.fullname = newfullname
    have-full-name()

condition_to_order = [
  <[ interactive link none ]>
  <[ interactive none link ]>
  <[ link interactive none ]>
  <[ link none interactive ]>
  <[ none interactive link ]>
  <[ none link interactive ]>
]

interactive-description = '''
This week, you will be shown quizzes that you can interact with directly inside your Facebook feed, without leaving it.<br>
It should look like this:<br><br>

<img src="feedlearn-screenshot.png" style="border-radius: 15px"></img>

<div>
<br><br>
<a href="geza@cs.stanford.edu">Email me</a> if you have already finished the pre-test for this week's vocabulary, but you do not see the quizzes in your Facebook feed.<br>
</div>
'''
link-description = '''
This week, you will be shown notifications inside your feed asking you to visit the FeedLearn website.<br>
It should look like this:<br><br>

<img src="feedlearn-link-screenshot.png" style="border-radius: 15px"></img>

<div>
<br><br>
<a href="geza@cs.stanford.edu">Email me</a> if you have already finished the pre-test for this week's vocabulary, but you do not see the links in your Facebook feed.
</div>
'''
none-description = '''
This week, you will not be shown quizzes in your Facebook feed, but will rather be sent a daily email reminder asking you to visit the <a href="/?webvisit=true" target="_blank">FeedLearn website</a> to study.<br>
The email will come around 10AM each day (Pacific Time). Please do not mark it as spam.<br>
It should look like this:<br><br>

<img src="feedlearn-email-screenshot.png" style="border-radius: 15px"></img>

<div>
<br><br>
<a href="geza@cs.stanford.edu">Email me</a> if you have already finished the pre-test for this week's vocabulary, but you do not receive the daily email by the next day at 11AM.
</div>
'''

get-description-for-format-and-week = (format, weeknum) ->
  firstpart = switch weeknum
  | 0 => 'After you have completed the pretest, you will be studying the week 1 vocabulary as follows:'
  | 1 => 'After you have completed the pretest, you will be studying the week 2 vocabulary as follows:'
  | 2 => 'After you have completed the pretest, you will be studying the week 3 vocabulary as follows:'
  format-description = switch format
  | 'interactive' => interactive-description
  | 'link' => link-description
  | 'none' => none-description
  return $('<div>').append [$('<div>').text(firstpart), $('<div>').html(format-description)]

set-week1-description = (format) ->
  desctext = get-description-for-format-and-week(format, 0)
  $('#week1desc').html desctext

set-week2-description = (format) ->
  desctext = get-description-for-format-and-week(format, 1)
  $('#week2desc').html desctext

set-week3-description = (format) ->
  desctext = get-description-for-format-and-week(format, 2)
  $('#week3desc').html desctext


set-studyorder = (studyorder) ->
  set-week1-description studyorder[0]
  set-week2-description studyorder[1]
  set-week3-description studyorder[2]
  return

show-pretest-done = (num, timestamp) ->
  if not timestamp?
    timestamp = Date.now()
  readable = moment(timestamp).format('llll')
  $('#pretest' + num + 'check').css 'visibility', 'visible'
  $('#pretest' + num + 'button').attr 'disabled', true
  $('#pretest' + num + 'donedisplay').css('color', 'green').text 'You submitted pre-test ' + num + ' on ' + readable

show-posttest-done = (num, timestamp) ->
  if not timestamp?
    timestamp = Date.now()
  readable = moment(timestamp).format('llll')
  $('#posttest' + num + 'check').css 'visibility', 'visible'
  $('#posttest' + num + 'button').attr 'disabled', true
  $('#posttest' + num + 'donedisplay').css('color', 'green').text 'You submitted post-test ' + num + ' on ' + readable

show-consent-agreed = (timestamp) ->
  if not timestamp?
    timestamp = Date.now()
  readable = moment(timestamp).format('llll')
  $('#consentcheck').css 'visibility', 'visible'
  $('#consentbutton').attr 'disabled', true
  $('#consentdisplay').css('color', 'green').text 'You agreed to this on ' + readable

show-studyperiod-started = (num, timesamp) ->
  if not timestamp?
    timestamp = Date.now()
  readable = moment(timestamp).format('llll')
  oneweeklater = moment(timestamp + 1000*3600*24*7).format('llll')
  $('#startweek' + num + 'check').css 'visibility', 'visible'
  $('#startweek' + num + 'button').attr 'disabled', true
  message1 = $('<div>').text 'You started the week ' +  num + ' study period at ' + readable
  message2 = $('<div>').text 'Please return one week later to take post-test ' + num + ' at ' + oneweeklater
  $('#startweek' + num + 'donedisplay').attr('color', 'green').html $('<div>').append([message1, message2])

root.completed-parts = {}

open-part-that-needs-doing = ->
  events = root.completed-parts
  
  if not events.consentagreed? # consent
    $('#collapseOne').data 'allowcollapse', false
    $('#collapseOne').collapse('show')
    return
  $('#collapseOne').data 'allowcollapse', true
  
  if $('#extensioninstalledcheck').css('visibility') != 'visible' # extension
    $('#collapseThree').data 'allowcollapse', false
    $('#collapseThree').collapse('show')
    return
  $('#collapseThree').data 'allowcollapse', true
  if not events.extensionfirstinstalled?
    post-start-event 'extensionfirstinstalled'
  
  if not events['posttest1']?
    $('#collapseTwo').data 'allowcollapse', false
    $('#collapseTwo').collapse('show')
    return
  $('#collapseTwo').data 'allowcollapse', true

  if not events['posttest2']?
    $('#collapseSix').data 'allowcollapse', false
    $('#collapseSix').collapse('show')
    return
  $('#collapseSix').data 'allowcollapse', true

  if not events['posttest3']?
    $('#collapseNine').data 'allowcollapse', false
    $('#collapseNine').collapse('show')
    return
  $('#collapseNine').data 'allowcollapse', true

  if true # do not track currently if the survey was taken
    $('#collapseTen').data 'allowcollapse', false
    $('#collapseTen').collapse('show')
    return
  $('#collapseTen').data 'allowcollapse', true
  return

setup-accordion-elem = (elemname) ->
  elem = $('#' + elemname)
  elem.data 'allowcollapse', true
  elem.on 'hide.bs.collapse', ->
    if elem.data('allowcollapse')
      return true
    else
      return false
  return

prevent-accordion-collapsing = ->
  setup-accordion-elem 'collapseOne'
  setup-accordion-elem 'collapseThree'
  setup-accordion-elem 'collapseTwo'
  setup-accordion-elem 'collapseSix'
  setup-accordion-elem 'collapseNine'
  setup-accordion-elem 'collapseTen'

root.is_first_time_fetching_events = true

refresh-completed-parts = ->
  num_events_prev = -1
  get-user-events (events) ->
    have_new_events = root.is_first_time_fetching_events
    for k,v of events
      if not root.completed-parts[k]?
        root.completed-parts[k] = v
        have_new_events = true
      #if v != root.completed-parts[k]
      #  root.completed-parts[k] = v
      #  have_new_events = true
    if not have_new_events
      return
    root.is_first_time_fetching_events = false
    if events.consentagreed?
      show-consent-agreed(events.consentagreed)
    for num in [1,2,3]
      if events['pretest' + num]?
        show-pretest-done(num, events['pretest' + num])
        if events['posttest' + num]?
          $('#week' + num + 'posttesttime').text('You have already taken the post-test for week ' + num + ' vocabulary.')
        else if Date.now() > events['pretest' + num] + 1000*3600*24*7
          $('#week' + num + 'posttesttime').text('Please take the post-test for week ' + num + ' vocabulary now.')
        else
          $('#week' + num + 'posttesttime').text('Please revisit this page on ' + moment(events['pretest' + num] + 1000*3600*24*7).format('llll') + ' to take the post-test for week ' + num + ' vocabulary.')
      if events['posttest' + num]?
        show-posttest-done(num, events['posttest' + num])
      #if events['week' + num + 'startstudy']?
      #  show-studyperiod-started(num, events['week' + num + 'startstudy'])
    for num in [3,2,1]
      #if events['week' + num + 'startstudy']?
      if events['pretest' + num]? #or num == 1
        config-week(num)
        break
    open-part-that-needs-doing()

export showStudyFormatDescriptions = ->
  studyformatdescriptions = {
    'interactive': 'you will be shown vocabulary quizzes directly in your feed'
    'link': 'you will be shown links in your feed asking you to go to the FeedLearn site to do the quizzes.'
    'none': 'you will be sent daily email reminders to study Japanese on the FeedLearn site.'
  }
  $('#week1format').text studyformatdescriptions[root.studyorder[0]]
  $('#week2format').text studyformatdescriptions[root.studyorder[1]]
  $('#week3format').text studyformatdescriptions[root.studyorder[2]]

export have-full-name = ->
  updatecookiesandevents ->
    #setvar 'fullname', root.fullname
    $('#getfullname').hide()
    $('#fbloginpage').hide()
    $('#accordion').show()
    $('#fullnamedisplay').text  ' ' + root.fullname
    addlog {type: 'study1visit'}
    get-condition (condition) ->
      root.condition = condition
      setvar 'condition', root.condition
      root.studyorder = condition_to_order[condition]
      set-studyorder root.studyorder
      show-study-format-descriptions()
      refresh-completed-parts()
      setInterval ->
        refresh-completed-parts()
      , 2000

/*
fb-login-status-change-callback = (response) ->
  if response.status == 'connected'

  setvar 'fullname', response.name
  addlog {type: 'fblogin', logintype: 'automatic', fblogin: response}
  addlogfblogin {type: 'fblogin', logintype: 'automatic', fblogin: response}
  #window.location.href = '/study1'
  have-full-name()
*/

export fb-try-login-automatic = ->
  FB.get-login-status (loginstatus) ->
    if loginstatus.status != 'connected'
      return
    FB.api '/me', (response) ->
      if response.name?
        setvar 'fullname', response.name
        addlog {type: 'fblogin', logintype: 'automatic', fblogin: response}
        addlogfblogin {type: 'fblogin', logintype: 'automatic', fblogin: response}
        have-full-name()

export fb-try-login-manual = ->
  FB.get-login-status (loginstatus) ->
    if loginstatus.status != 'connected'
      return
    FB.api '/me', (response) ->
      if response.name?
        setvar 'fullname', response.name
        addlog {type: 'fblogin', logintype: 'manual', fblogin: response}
        addlogfblogin {type: 'fblogin', logintype: 'manual', fblogin: response}
        have-full-name()

window.fbAsyncInit = ->
  console.log 'fbAsyncInit called'
  appid = getFBAppId()
  FB.init {
    appId  : appid
    cookie : true  # enable cookies to allow the server to access the session
    xfbml  : true #true # true,  # parse social plugins on this page
    version: 'v2.1' # use version 2.1
  }
  fb-try-login-automatic()

inject-facebook-tag = ->
  console.log 'inject-facebook-tag called'
  e = document.createElement('script')
  e.async = true
  e.src = '//connect.facebook.net/en_US/sdk.js'
  document.getElementById('fb-root').appendChild e

export dont-have-full-name = ->
  inject-facebook-tag()

export fbButtonOnlogin = ->
  fb-try-login-manual()

#export fb-login-button-clicked = ->
#  #FB.login ->
#  #  fb-try-login-manual()

$(document).ready ->
  forcehttps()
  setvar 'hideoption', true
  param = getUrlParameters()
  root.fullname = first-non-null param.fullname, param.username, param.user, param.name
  if root.fullname?
    setvar 'fullname', root.fullname
    window.location.href = '/study1'
    return
  if not window.chrome?
    toastr.options = {
      showDuration: 0
      hideDuration: 0
      timeOut: 0
      extendedTimeOut: 0
    }
    toastr.error 'FeedLearn currently only supports the Google Chrome browser'
  fbname = getvar 'fbname'
  if fbname?
    setvar 'fbname', fbname
  fburl = getvar 'fburl'
  if fburl?
    setvar 'fburl', fburl
  root.fullname = first-non-null root.fullname, getvar('fullname'), getvar('username'), fbname #, 'Anonymous User'
  prevent-accordion-collapsing()
  if root.fullname? and root.fullname != 'Anonymous User' and root.fullname.length > 0
    have-full-name()
  else
    dont-have-full-name()

    

