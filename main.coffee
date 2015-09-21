is_same_page = (url) ->
  location.pathname.indexOf(url) > -1
is_in_find_work_page = ->
  is_same_page 'find-work-home'
is_in_saved_jobs_page = ->
  is_same_page 'jobs/saved'
is_in_proposals_page = ->
  is_same_page 'applications/active'
is_should_show_counters = ->
  is_in_find_work_page() or is_in_saved_jobs_page()

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

init_counters = ->
  if is_should_show_counters()
    jobs = get_jobs_elements()

    Array::forEach.call jobs, (job) ->
      load_counters_data_for(job)

pseudo_callback = ->
  # setTimeout init_counters, 10 * 1000

init_counters()
setInterval init_counters, 60 * 1000
if is_in_find_work_page()
  moreJobsButton = document.getElementById('jsLoadMoreJobs')
  freshJobsButton = document.getElementById('')

  moreJobsButton?.addEventListener 'click', pseudo_callback
  freshJobsButton?.addEventListener 'click', pseudo_callback

if is_in_proposals_page()
  content_tables = document.getElementsByTagName 'table'
  Array::forEach.call content_tables, (content_table) ->
    header = content_table.getElementsByTagName('thead')[0]
    content = content_table.getElementsByTagName('tbody')[0]
    links = content.getElementsByTagName 'a'

    Array::forEach.call links, (link) ->
      url = link.getAttribute('href')
      xhr = new XMLHttpRequest
      xhr.open 'GET', url
      xhr.onreadystatechange = ->
        if xhr.response and xhr.response.length
          target_phrase = 'Activity for this job'
          target_segmant = xhr.response.substr(xhr.response.indexOf(target_phrase) + target_phrase.length, 250)
          target_segmant = target_segmant.split 'li'
          target_segmant.shift()
          console.log target_segmant
      xhr.send()
