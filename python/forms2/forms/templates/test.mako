<%inherit file="base.mako"/>
<%def name="logout()">
<li><a href="/logout"><a href="/logout">Logout</a></li>
</%def>

<div class="row">
  <div class="small-2 large-4 columns">
   <div class="button-span5">
	<h4>Employees</h4>
	<a class="btn" href="/employee/list">View Employees »</a>
	<br/>
	<br/>
	<a class="btn primary"  href="/employee/new">New Employee »</a>
    </div>
  </div>

  <div class="small-4 large-4 columns">
    <div class="button-span5">
	<h4>Departments</h4>
	<a class="btn" href="/departments/list">View Departments »</a>
	<br/>
	<br/>
	<a class="btn primary" href="/department/new">New Department »</a>
    </div>
  </div>

  <div class="small-6 large-4 columns">
   <div class="button-span5">
	<h4>Appraisals</h4>
	<a class="btn" href="/appraisals/list">View Appraisals »</a>
	<br/>
	<br/>
	<a class="btn primary" href="/appraisals/new">New Appraisal »</a>
    </div>
  </div>
</div>

