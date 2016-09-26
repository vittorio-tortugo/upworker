API_JOB_SEARCH_URL = "https://www.upwork.com/ab/find-work/api/feeds/search"

getApplicantsUrl = (jobCiphertext) ->
  return "https://www.upwork.com/jobs/#{jobCiphertext}/applicants"

loadingStack = []

observer = new MutationObserver (mutations) ->

  mutations.forEach (mutation) ->
    addedNodes = mutation.addedNodes

    if addedNodes.length
      addedNodes.forEach (node) ->
        if node.tagName == "ARTICLE"
          $el = $(node)

          if $el.data('id')
            id = $el.data('id')
          else
            $link = $el.find('.job-title-link')
            id = $link.attr('href').replace("/jobs/_", "").replace("/","")

          loadingStack.push({
            $el: $el
            id: id
          })

config =
  childList: true
  subtree: true

observer.observe(document, config)

setInterval ->
  if loadingStack.length
    item = loadingStack.shift()
    $.get getApplicantsUrl(item.id), (data) ->
      console.log(data)
      applicants = data.applicantsCount
      interview = data.invitedToInterview
      item.$el.append("<div>Applicants: #{applicants} | Interview: #{interview}</div>")
, 300
