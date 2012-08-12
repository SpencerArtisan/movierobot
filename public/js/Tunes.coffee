window.Movie = Backbone.Model.extend()

window.Movies = Backbone.Collection.extend(
  model: Movie,
  url: "/films",
  comparator : (movie) ->
    - movie.get('rating')
)

window.library = new Movies()

window.MovieView = Backbone.View.extend(
    tagName: 'li',
    className: 'movie',

    initialize: ->
                  @template = _.template($('#movie-template').html())

    render: ->
              renderedContent = @template(@model.toJSON())
              $(@el).html(renderedContent)
              this
  )

window.LibraryMovieView = MovieView.extend(
)

window.LibraryView = Backbone.View.extend(
  tagName: 'section',
  className: 'library'

  initialize: ->
    _.bindAll(this, 'render')
    @template = _.template($('#library-template').html())
    @collection.bind('reset', @render)

  render: ->
    collection = @collection

    $(@el).html(@template())
    $movies = @$('.movies')
    collection.each( (movie) ->
      view = new LibraryMovieView(
        model: movie,
        collection: collection
      )
      $movies.append(view.render().el)
    )
    this
)

window.BackboneMovies = Backbone.Router.extend(
  routes:
    '': 'home'

  initialize: ->
    @libraryView = new LibraryView(
      collection: window.library
    )

  home: ->
    $container = $('#container')
    $container.empty()
    $container.append(@libraryView.render().el)
)

$( ->
  window.App = new BackboneMovies()
  Backbone.history.start()
)
