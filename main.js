if (location.pathname.indexOf('find-work-home') > -1) {
  var jobsWrapper = document.getElementById('jsJobResults');
  var jobs = jobsWrapper.getElementsByTagName('article');

  Array.prototype.forEach.call(jobs, function(job) {
    var url = job.getAttribute('data-id');
    var xhr = new XMLHttpRequest();

    xhr.open('GET', '/jobs/' + url + '/applicants');

    xhr.onreadystatechange = function() {
      if(xhr.readyState !== 4) {
        return
      }
      if (xhr.response && xhr.response.length) {
        response = JSON.parse(xhr.response);
        var applicants_count = response.applicants.length;
        var interviewing_count = response.invitedToInterview;

        element = document.createElement('span');
        element.innerText = 'Applicants: ' + applicants_count + ' | ' + 'Interviewing: ' + interviewing_count;
        job.appendChild(element);
      }
    }
    xhr.send();
  });
}
