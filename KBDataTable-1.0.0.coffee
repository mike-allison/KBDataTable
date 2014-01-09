### 
 * Mike Allison Tools - KBDataTable v.1.0.0
 * http://mikeallisononline.com/
 *
 * Dependent on Knockback and jQuery (for scrolling)
 * http://kmalakoff.github.io/knockback/
 * http://jquery.com/
 *
 * Optional table scrolling with jTableScroll
 * http://mikeallisononline.com/
 *
 * Copyright 2013 Mike Allison
 * Released under the MIT license
 * http://opensource.org/licenses/MIT
 ###

window.KBDataTableModel = Backbone.Model.extend(
    defaults :
        "searchText": ""
        "columns": []
        "rows": new Backbone.Collection
        "currentPage": 0           
        "pageSize": 20
        "selectedColumn": 0
        "tableHeight": 0
        "tableWidth": 0
        "sortDir": []
        "autoSearch": true
        "selectedRow": null
        "nextFn": null,
        "prevFn": null,
        "searchFn": null,
        "sortFn": null,
        "lastFn": null,
        "firstFn": null,
        "selectFn": null
)
        

class window.KBDataTableViewModel
    constructor: (@model) ->    
        @searchText = kb.observable @model, 'searchText'
        @columns = kb.observable @model, 'columns'
        @rows = new kb.CollectionObservable @model.attributes.rows
        @currentPage = kb.observable @model, 'currentPage'
        @pageSize = kb.observable @model, 'pageSize'
        @selectedColumn = kb.observable @model, 'selectedColumn'
        @tableHeight = @model.get('tableHeight')
        @tableWidth = @model.get('tableWidth')
        @sortDir = @model.get('sortDir')
        @autoSearch = @model.get('autoSearch')
        @selectedRow = kb.observable @model, 'selectedRow'
        @filter = ko.observable @searchText()
        if @autoSearch 
            @throttleSearch = ko.computed =>            
                @filter @searchText()
            @throttleSearch.extend throttle : 300                    
            
        @filteredRows = ko.computed =>            
            filter = @filter().toLowerCase()                
                
            if not filter 
                @rows()
            else
                ko.utils.arrayFilter @rows(), (item) =>
                    item.model().get([@selectedColumn()]).toString().toLowerCase().indexOf(filter) > -1
            
        @currentRows = ko.computed =>
            if (@currentPage() + 1) * @pageSize() > @filteredRows().length
                @filteredRows()[(@currentPage() * @pageSize())..]
            else
                @filteredRows()[(@currentPage() * @pageSize())..((@currentPage() + 1 * @pageSize()) - 1)]
        
        @pageCount = ko.computed =>
            Math.ceil(@filteredRows().length / @pageSize())
        
        @nextFn = @model.get 'nextFn' ? null
        @prevFn = @model.get 'prevFn' ? null
        @searchFn = @model.get 'searchFn' ? null
        @sortFn = @model.get 'sortFn' ? null
        @lastFn = @model.get 'lastFn' ? null
        @firstFn = @model.get 'firstFn' ? null
        @selectFn = @model.get 'selectFn' ? null

        if typeof jQuery.fn.jTableScroll is "function"
            jQuery =>
                jQuery('.jTableScroll').jTableScroll({ height: @tableHeight, width: @tableWidth })

    nextPage: ->        
        if (@currentPage() + 1) * @pageSize() < @filteredRows().length            
            @nextFn?()
            @currentPage(@currentPage() + 1)

    prevPage: ->
        if @currentPage() > 0
            @prevFn?()
            @currentPage(@currentPage() - 1)
    lastPage: ->                
            @lastFn?()
            @currentPage(Math.ceil(@filteredRows().length / @pageSize()) - 1)

    firstPage: ->
            @firstFn?()
            @currentPage(0)
    search: ->
            @searchFn?()  
            @filter @searchText() 
            @currentPage 0
    sort: (index) ->        
        if @sortFn is "function"
            @sortFn index
        else
            @sortDir[index] = "A" if not @sortDir[index]
               
            @rows.sort (left, right) =>
                if @sortDir[index] == "A"
                    if left.model().get(@columns()[index]) == right.model().get(@columns()[index]) then 0 else if left.model().get(@columns()[index]) < right.model().get(@columns()[index]) then -1 else 1
                else 
                    if left.model().get(@columns()[index]) == right.model().get(@columns()[index]) then 0 else if left.model().get(@columns()[index]) > right.model().get(@columns()[index]) then -1 else 1
            @sortDir[index] = @sortDir[index] == "A" ? "D" : "A";
    selectRow: (data) ->
        @selectedRow data.model().cid
        @selectFn?()
