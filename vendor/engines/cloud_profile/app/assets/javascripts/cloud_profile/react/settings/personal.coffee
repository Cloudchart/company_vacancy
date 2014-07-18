#
#
tag = React.DOM

LetterAvatarComponent = cc.require('react/shared/letter-avatar')


# Component
#
Component = React.createClass


  onSaveDone: (json) ->
    @setState
      name:           json.full_name
      prevName:       json.full_name
      avatar_url:     json.avatar_url
      src:            null unless json.avatar_url
      prevSrc:        null unless json.avatar_url
      synchronizing:  false
  
  
  onSaveFail: (xhr) ->
    @setState
      name:           @state.prevName
      src:            @state.prevSrc
      synchronizing:  false


  save: ->
    @setState
      should_save:    false
      synchronizing:  true
    
    data = new FormData

    data.append('user[full_name]',      @state.name)
    data.append('user[avatar]',         @state.file) if @state.file
    data.append('user[remove_avatar]',  true) unless @state.file or @state.src
    
    $.ajax
      url:          @props.url
      type:         'PUT'
      dataType:     'json'
      data:         data
      contentType:  false
      processData:  false
    .done @onSaveDone
    .fail @onSaveFail
      
    
  renderImage: ->
    image     = new Image
    image.src = @state.avatar_url

    image.onload = =>
      @setState
        src:        @state.avatar_url
        prevSrc:    @state.avatar_url
        avatar_url: null


  occupations: ->
    @props.people.map (person) =>
      company = @props.companies.filter((company) -> company.uuid == person.company_id)[0]
      (tag.li { key: company.uuid },
        (person.occupation || 'Nobody')
        ' at '
        (tag.a { href: company.url }, company.name)
      )
  
  
  onFileChange: (event) ->
    file      = event.target.files[0]
    image     = new Image
    image.src = URL.createObjectURL(file)

    image.onload = =>
      @setState({ src: image.src, file: file, should_save: true })
    
    image.onerror = =>
      # show alert
  
  
  onFileDelete: (event) ->
    @setState({ src: null, file: null, should_save: true })
  

  onNameChange: (event) ->
    @setState
      name: event.target.value
  

  onNameBlur: (event) ->
    @setState({ should_save: true }) unless @state.name is @state.prevName
  
  
  onNameKeyUp: (event) ->
    switch event.key

      when 'Escape'
        @setState({ name: @state.prevName })

      when 'Enter'
        @refs.input.getDOMNode().blur()
  
  
  componentDidUpdate: ->
    @save()         if @state.should_save
    @renderImage()  if @state.avatar_url
  

  getInitialState: ->
    name:     @props.full_name
    prevName: @props.full_name
    src:      @props.avatar_url
    prevSrc:  @props.avatar_url


  render: ->
    occupations = @occupations()
    
    (tag.div { className: 'content' },
    
      (tag.aside {
        className: 'avatar'
        style:
          backgroundImage: "url(#{@state.src || ''})"
      },
        
        (tag.input {
          id:         'file-input'
          type:       'file'
          value:      ''
          onChange:   @onFileChange
        })

        (tag.label {
          htmlFor:    'file-input'
          className:  'orgpad-button small square create'
        },
          (tag.i { className: 'fa fa-magic' })
        ) unless @state.src


        (tag.label {
          htmlFor:    'file-input'
          className:  'orgpad-button small update'
        },
          'Change'
        ) if @state.src

        (tag.button {
          type:       'reset'
          className:  'orgpad small alert delete'
          onClick:    @onFileDelete
        },
          'Delete'
        ) if @state.src

        (LetterAvatarComponent {
          string: @state.name
        }) unless @state.src
        
        (tag.p { className: 'overlay' }) if @state.src
      )

      (tag.input {
        ref:            'input'
        type:           'text'
        autoComplete:   'off'
        placeholder:    'Name Surname'
        className:      'name'
        value:          @state.name
        onChange:       @onNameChange
        onBlur:         @onNameBlur
        onKeyUp:        @onNameKeyUp
      })

      (tag.ul { className: 'occupations' }, occupations) if occupations.length > 0
    )


#
#
cc.module('profile/react/settings/personal').exports = Component
