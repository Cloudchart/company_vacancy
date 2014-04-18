<%- if @email.valid? -%>
  $('section.emails ul').append('<%= j render partial: "token", object: @token -%>')
  $('section.emails form').remove()
<%- else -%>
  $('section.emails form').replaceWith('<%= j render partial: "new_email_form", locals: { email: @email } -%>')
<%- end -%>
