#
#
tag = React.DOM

LetterAvatarComponent = cc.require('react/shared/letter-avatar')


# Component
#
Component = React.createClass


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
      @setState({ src: image.src, file: file })
    
    image.onerror = =>
      # show alert
  
  
  onFileDelete: (event) ->
    @setState({ src: null, file: null })
  

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
    # @save() if @state.should_save
  

  getInitialState: ->
    initName = [@props.first_name, @props.last_name].filter((name) -> name and name.trim().length > 0).join(' ')

    name:     initName
    prevName: initName
    src:      @props.avatar_url


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
