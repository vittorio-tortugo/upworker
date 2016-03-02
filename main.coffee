load_stack = []

is_same_page = (url) ->
  location.pathname.indexOf(url) > -1

is_in_find_work_page = ->
  is_same_page('find-work-home') || is_same_page('find-work')

is_in_saved_jobs_page = ->
  is_same_page 'jobs/saved'

is_in_proposals_page = ->
  is_same_page 'applications/active'

is_should_show_counters = ->
  is_in_find_work_page() || is_in_saved_jobs_page()

get_jobs_elements = ->
  jobsWrapper = document.getElementsByTagName('section')[0]
  jobsWrapper.getElementsByTagName('article')

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
  url = "/jobs/#{url}/applicants"

  load_stack.push({url: url, el: jobEl})

load_counters_data_by = (url, callback) ->
  xhr = new XMLHttpRequest
  xhr.open('GET', url)

  xhr.onreadystatechange = ->
    if xhr.readyState == 4
      if xhr.response?.length
        response = JSON.parse(xhr.response)
        callback(response)
  xhr.send()

init_counters = ->
  if is_should_show_counters()
    jobs = get_jobs_elements()

    Array::forEach.call jobs, (job) ->
      load_counters_data_for(job)

init_counters()

setInterval ->
  if load_stack.length
    job = load_stack.shift()
    load_counters_data_by(job.url, (response) ->
      show_counters(response, job.el)
    )
, 100


setInterval ->
  init_counters()
, 2 * 60 * 1000

if is_in_find_work_page()
  wrapper = document.getElementById('jsJobResults')
  observer = new MutationObserver (mutations) ->
    mutations.forEach (mutation) ->
      if mutation.addedNodes && mutation.addedNodes.length
        for node in mutation.addedNodes
          if node.tagName == 'ARTICLE'
            load_counters_data_for(node)

  observer.observe(wrapper, {childList: true})
