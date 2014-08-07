<%inherit file="base.mako"/>
      <h3>Employee Registration</h3>

      ## flash any messages in the session flash queue
      % for msg in request.session.pop_flash():
      <div data-alert class="alert-box success">
          ${msg}
          <a href="#" class="close">&times;</a>
      </div>
      % endfor

      <div class="section-container auto" data-section>
        <section class="section">
          <h5 class="title"><a href="#panel1">Employee</a></h5>
          <div class="content" data-slug="panel1">
            <form formid="employeeform" method="post" action="${request.route_url('home')}">
              ## fields are keyed by name in deform `Form` objects
              ${render_input_field(form['Firstname'])}
	      ${render_input_field(form['Surname'])}  
              ${render_input_field(form['department'])}
              ${render_input_field(form['employee_type'])}
	      ${render_input_field(form['Username'])}
	      ${render_input_field(form['Password'])}
              <input type="submit" name="submit" value="Submit" class="radius button"/>
            </form>
          </div>
        </section>
	</div>
<!--
        <section class="section">
	  <h5 class="title"><a href="#panel2">User Login</a></h5>
	  <div class="content" data-slug="panel2">
            <form formid="employeeform" method="post" action="${request.route_url('home')}">
		 ${render_input_field(form['Username'])}
	          <input type="submit" name="submit" value="Submit" class="radius button"/>
	    </form>
          </div>
        </section>

      </div>

    
      <ul style="list-style-position:inside;">
        <li>Submit the form with one or more blank fields</li>
        <li>Submit the form with a malformed email address (like "me@here")</li>
        <li>Submit the form with a well-formed email address and all fields
            filled in</li>
      </ul>
-->
    <!-- End Contact Details -->



## helper function to render a text input field

<%def name="render_input_field(field)">
    ## include the foundation error class if this field had an error
    % if field.error:
        <div class="row collapse error">
    % else:
        <div class="row collapse">
    % endif

        ## display the field's title as a label
          <div class="large-2 columns">
              <label class="inline">${field.title}</label>
          </div>

        ## serialize the field (filter with "|n" so it won't escape the html)
          <div class="large-10 columns">
              ${field.serialize()|n}

              ## render any error messages if present
              ${render_error(field.error)}
          </div>

        </div>
</%def>


## helper function to render a textarea field

<%def name="render_textarea(field)">
    ## include the foundation error class if this field had an error
    % if field.error:
        <div class="row collapse error">
    % else:
        <div class="row collapse">
    % endif

        ## render the label, textarea, and possibly error messages
            <label>${field.title}</label>
            ${form['comment'].serialize()|n}
            ${render_error(field.error)}

        </div>
</%def>


## helper function to render error messages if the field has any errors

<%def name="render_error(error)">
    ## include any error messages if present
    % if error:
        % for e in error.messages():
            <small>${e}</small>
        % endfor
    % endif
</%def>


## template source code link
