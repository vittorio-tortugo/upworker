// Generated by CoffeeScript 1.10.0
(function() {
  var get_jobs_elements, init_counters, is_in_find_work_page, is_in_proposals_page, is_in_saved_jobs_page, is_same_page, is_should_show_counters, load_counters_data_by, load_counters_data_for, load_stack, observer, show_counters, wrapper;

  load_stack = [];

  is_same_page = function(url) {
    return location.pathname.indexOf(url) > -1;
  };

  is_in_find_work_page = function() {
    return is_same_page('find-work-home') || is_same_page('find-work');
  };

  is_in_saved_jobs_page = function() {
    return is_same_page('jobs/saved');
  };

  is_in_proposals_page = function() {
    return is_same_page('applications/active');
  };

  is_should_show_counters = function() {
    return is_in_find_work_page() || is_in_saved_jobs_page();
  };

  get_jobs_elements = function() {
    var jobsWrapper;
    jobsWrapper = document.getElementsByTagName('section')[0];
    return jobsWrapper.getElementsByTagName('article');
  };

  show_counters = function(data, jobEl) {
    var applicants_count, counters, el, interviewing_count;
    applicants_count = data.applicants.length;
    interviewing_count = data.invitedToInterview;
    counters = jobEl.getElementsByClassName('counters');
    if (counters.length) {
      el = counters[0];
    } else {
      el = document.createElement('span');
      el.className = 'counters';
      jobEl.appendChild(el);
    }
    return el.innerText = "Applicants: " + applicants_count + " | Interviewing: " + interviewing_count;
  };

  load_counters_data_for = function(jobEl) {
    var url;
    url = jobEl.getAttribute('data-id');
    url = "/jobs/" + url + "/applicants";
    return load_stack.push({
      url: url,
      el: jobEl
    });
  };

  load_counters_data_by = function(url, callback) {
    var xhr;
    xhr = new XMLHttpRequest;
    xhr.open('GET', url);
    xhr.onreadystatechange = function() {
      var ref, response;
      if (xhr.readyState === 4) {
        if ((ref = xhr.response) != null ? ref.length : void 0) {
          response = JSON.parse(xhr.response);
          return callback(response);
        }
      }
    };
    return xhr.send();
  };

  init_counters = function() {
    var jobs;
    if (is_should_show_counters()) {
      jobs = get_jobs_elements();
      return Array.prototype.forEach.call(jobs, function(job) {
        return load_counters_data_for(job);
      });
    }
  };

  init_counters();

  setInterval(function() {
    var job;
    if (load_stack.length) {
      job = load_stack.shift();
      return load_counters_data_by(job.url, function(response) {
        return show_counters(response, job.el);
      });
    }
  }, 100);

  setInterval(function() {
    return init_counters();
  }, 2 * 60 * 1000);

  if (is_in_find_work_page()) {
    wrapper = document.getElementById('jsJobResults');
    observer = new MutationObserver(function(mutations) {
      return mutations.forEach(function(mutation) {
        var i, len, node, ref, results;
        if (mutation.addedNodes && mutation.addedNodes.length) {
          ref = mutation.addedNodes;
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            node = ref[i];
            if (node.tagName === 'ARTICLE') {
              results.push(load_counters_data_for(node));
            } else {
              results.push(void 0);
            }
          }
          return results;
        }
      });
    });
    observer.observe(wrapper, {
      childList: true
    });
  }

}).call(this);
