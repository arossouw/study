<%inherit file="base.mako"/>
<%def name="logout()">
<li>&nbsp;</li>
</%def>
    <!-- Login Details -->


      ## flash any messages in the session flash queue
      % for msg in request.session.pop_flash():
      <div data-alert class="alert-box success">
          ${msg}
          <a href="#" class="close">&times;</a>
      </div>
      % endfor

     <div class="section-container auto" data-section>
        <section class="section">
          <h5 class="title"><a href="#panel1">Login</a></h5>
          <div class="content" data-slug="panel1">
            <form formid="employeeform" method="post" action="${request.route_url('login')}">
              ## fields are keyed by name in deform `Form` objects
              ${render_input_field(form['username'])}
	      ${render_input_field(form['password'])}  
              <input type="submit" name="submit" value="Submit" class="radius button"/>
            </form>
          </div>
        </section>
	</div>

    <!-- End Login Details -->



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


## helper function to render error messages if the field has any errors

<%def name="render_error(error)">
    <%doc>
      Note: we use our own translate filter here to handle deform error messages
      with the TranslationString type (they require additional processing
      before rendering).
    </%doc>

    ## include any error messages if present
    % if error:
        % for e in error.messages():
            <small>${e|n,translate}</small>
        % endfor
    % endif
</%def>

