is_should_show_counters = ->
  return true if location.pathname.indexOf('find-work-home') > -1
  return true if location.pathname.indexOf('/jobs/saved') > -1
  return false

get_jobs_elements = ->
  jobsWrapper = document.getElementsByTagName('section')[0]
  jobs = jobsWrapper.getElementsByTagName('article')

show_counters = (data, jobEl) ->
  applicants_count = data.applicants.length
  interviewing_count = data.invitedToInterview
  counters = jobEl.getElementsByClassName('counters')
  if counters.length
    el = counters[0]
  else
    el = document.createElement('span')
    el.className = 'counters'
    jobEl.appendChild el
  el.innerText = "Applicants: #{applicants_count} | Interviewing: #{interviewing_count}"

load_counters_data_for = (jobEl) ->
  url = jobEl.getAttribute('data-id')
  xhr = new XMLHttpRequest
  xhr.open 'GET', '/jobs/' + url + '/applicants'

  xhr.onreadystatechange = ->
    return unless xhr.readyState is 4
    if xhr.response and xhr.response.length
      response = JSON.parse(xhr.response)
      show_counters(response, jobEl)
  xhr.send()

if is_should_show_counters()
  jobs = get_jobs_elements()

  Array::forEach.call jobs, (job) ->
    load_counters_data_for(job)
