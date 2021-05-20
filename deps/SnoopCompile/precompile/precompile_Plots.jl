# Use
#    @warnpcfail precompile(args...)
# if you want to be warned when a precompile directive fails
macro warnpcfail(ex::Expr)
    modl = __module__
    file = __source__.file === nothing ? "?" : String(__source__.file)
    line = __source__.line
    quote
        $(esc(ex)) || @warn """precompile directive
     $($(Expr(:quote, ex)))
 failed. Please report an issue in $($modl) (after checking for duplicates) or remove this directive.""" _file=$file _line=$line
    end
end


const __bodyfunction__ = Dict{Method,Any}()

# Find keyword "body functions" (the function that contains the body
# as written by the developer, called after all missing keyword-arguments
# have been assigned values), in a manner that doesn't depend on
# gensymmed names.
# `mnokw` is the method that gets called when you invoke it without
# supplying any keywords.
function __lookup_kwbody__(mnokw::Method)
    function getsym(arg)
        isa(arg, Symbol) && return arg
        @assert isa(arg, GlobalRef)
        return arg.name
    end

    f = get(__bodyfunction__, mnokw, nothing)
    if f === nothing
        fmod = mnokw.module
        # The lowered code for `mnokw` should look like
        #   %1 = mkw(kwvalues..., #self#, args...)
        #        return %1
        # where `mkw` is the name of the "active" keyword body-function.
        ast = Base.uncompressed_ast(mnokw)
        if isa(ast, Core.CodeInfo) && length(ast.code) >= 2
            callexpr = ast.code[end-1]
            if isa(callexpr, Expr) && callexpr.head == :call
                fsym = callexpr.args[1]
                if isa(fsym, Symbol)
                    f = getfield(fmod, fsym)
                elseif isa(fsym, GlobalRef)
                    if fsym.mod === Core && fsym.name === :_apply
                        f = getfield(mnokw.module, getsym(callexpr.args[2]))
                    elseif fsym.mod === Core && fsym.name === :_apply_iterate
                        f = getfield(mnokw.module, getsym(callexpr.args[3]))
                    else
                        f = getfield(fsym.mod, fsym.name)
                    end
                else
                    f = missing
                end
            else
                f = missing
            end
        else
            f = missing
        end
        __bodyfunction__[mnokw] = f
    end
    return f
end

function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    Base.precompile(Tuple{Core.kwftype(typeof(Type)),NamedTuple{(:label, :blank), Tuple{Symbol, Bool}},Type{EmptyLayout}})
    Base.precompile(Tuple{Core.kwftype(typeof(Type)),NamedTuple{(:label, :width, :height), Tuple{Symbol, Symbol, Length{:pct, Float64}}},Type{EmptyLayout}})
    Base.precompile(Tuple{Core.kwftype(typeof(_make_hist)),NamedTuple{(:normed, :weights), Tuple{Bool, Nothing}},typeof(_make_hist),Tuple{Vector{Float64}, Vector{Float64}},Int64})
    Base.precompile(Tuple{Core.kwftype(typeof(_make_hist)),NamedTuple{(:normed, :weights), Tuple{Bool, Nothing}},typeof(_make_hist),Tuple{Vector{Float64}, Vector{Float64}},Tuple{Int64, Int64}})
    Base.precompile(Tuple{Core.kwftype(typeof(_make_hist)),NamedTuple{(:normed, :weights), Tuple{Bool, Nothing}},typeof(_make_hist),Tuple{Vector{Float64}},Symbol})
    Base.precompile(Tuple{Core.kwftype(typeof(_make_hist)),NamedTuple{(:normed, :weights), Tuple{Bool, Vector{Int64}}},typeof(_make_hist),Tuple{Vector{Float64}},Symbol})
    Base.precompile(Tuple{Core.kwftype(typeof(attr!)),NamedTuple{(:formatter,), Tuple{typeof(datetimeformatter)}},typeof(attr!),Axis})
    Base.precompile(Tuple{Core.kwftype(typeof(attr!)),NamedTuple{(:grid, :lims), Tuple{Bool, Tuple{Float64, Float64}}},typeof(attr!),Axis})
    Base.precompile(Tuple{Core.kwftype(typeof(attr!)),NamedTuple{(:grid, :lims, :flip), Tuple{Bool, Tuple{Float64, Float64}, Bool}},typeof(attr!),Axis})
    Base.precompile(Tuple{Core.kwftype(typeof(attr!)),NamedTuple{(:grid,), Tuple{Bool}},typeof(attr!),Axis})
    Base.precompile(Tuple{Core.kwftype(typeof(attr!)),NamedTuple{(:gridlinewidth, :grid, :gridalpha, :gridstyle, :foreground_color_grid), Tuple{Int64, Bool, Float64, Symbol, RGBA{Float64}}},typeof(attr!),Axis})
    Base.precompile(Tuple{Core.kwftype(typeof(attr!)),NamedTuple{(:guide,), Tuple{String}},typeof(attr!),Axis})
    Base.precompile(Tuple{Core.kwftype(typeof(attr!)),NamedTuple{(:guide_position, :guidefontvalign, :mirror, :guide), Tuple{Symbol, Symbol, Bool, String}},typeof(attr!),Axis})
    Base.precompile(Tuple{Core.kwftype(typeof(attr!)),NamedTuple{(:guidefonthalign, :guide_position, :mirror, :guide), Tuple{Symbol, Symbol, Bool, String}},typeof(attr!),Axis})
    Base.precompile(Tuple{Core.kwftype(typeof(attr!)),NamedTuple{(:lims, :flip, :ticks, :guide), Tuple{Tuple{Int64, Int64}, Bool, StepRange{Int64, Int64}, String}},typeof(attr!),Axis})
    Base.precompile(Tuple{Core.kwftype(typeof(attr!)),NamedTuple{(:lims,), Tuple{Tuple{Int64, Float64}}},typeof(attr!),Axis})
    Base.precompile(Tuple{Core.kwftype(typeof(attr!)),NamedTuple{(:scale, :guide), Tuple{Symbol, String}},typeof(attr!),Axis})
    Base.precompile(Tuple{Core.kwftype(typeof(default)),NamedTuple{(:shape,), Tuple{Symbol}},typeof(default)})
    Base.precompile(Tuple{Core.kwftype(typeof(default)),NamedTuple{(:titlefont, :legendfontsize, :guidefont, :tickfont, :guide, :framestyle, :yminorgrid), Tuple{Tuple{Int64, String}, Int64, Tuple{Int64, Symbol}, Tuple{Int64, Symbol}, String, Symbol, Bool}},typeof(default)})
    Base.precompile(Tuple{Core.kwftype(typeof(font)),NamedTuple{(:family, :pointsize, :halign, :valign, :rotation, :color), Tuple{String, Int64, Symbol, Symbol, Float64, RGBA{Float64}}},typeof(font)})
    Base.precompile(Tuple{Core.kwftype(typeof(gr_polyline)),NamedTuple{(:arrowside, :arrowstyle), Tuple{Symbol, Symbol}},typeof(gr_polyline),StepRangeLen{Float64, Base.TwicePrecision{Float64}, Base.TwicePrecision{Float64}},Vector{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(gr_polyline)),NamedTuple{(:arrowside, :arrowstyle), Tuple{Symbol, Symbol}},typeof(gr_polyline),StepRange{Int64, Int64},Vector{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(gr_polyline)),NamedTuple{(:arrowside, :arrowstyle), Tuple{Symbol, Symbol}},typeof(gr_polyline),UnitRange{Int64},UnitRange{Int64}})
    Base.precompile(Tuple{Core.kwftype(typeof(gr_polyline)),NamedTuple{(:arrowside, :arrowstyle), Tuple{Symbol, Symbol}},typeof(gr_polyline),UnitRange{Int64},Vector{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(gr_polyline)),NamedTuple{(:arrowside, :arrowstyle), Tuple{Symbol, Symbol}},typeof(gr_polyline),Vector{Int64},Vector{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(hline!)),Any,typeof(hline!),Any})
    Base.precompile(Tuple{Core.kwftype(typeof(plot!)),NamedTuple{(:alpha, :seriestype), Tuple{Float64, Symbol}},typeof(plot!),Plot{GRBackend},Vector{GeometryBasics.Point2{Float64}}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot!)),NamedTuple{(:alpha, :seriestype), Tuple{Float64, Symbol}},typeof(plot!),Plot{PlotlyBackend},Vector{GeometryBasics.Point2{Float64}}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot!)),NamedTuple{(:alpha, :seriestype), Tuple{Float64, Symbol}},typeof(plot!),Vector{GeometryBasics.Point2{Float64}}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot!)),NamedTuple{(:annotation,), Tuple{Vector{Tuple{Int64, Float64, PlotText}}}},typeof(plot!)})
    Base.precompile(Tuple{Core.kwftype(typeof(plot!)),NamedTuple{(:line, :seriestype), Tuple{Tuple{Int64, Symbol, Float64, Matrix{Symbol}}, Symbol}},typeof(plot!),Matrix{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot!)),NamedTuple{(:line, :seriestype), Tuple{Tuple{Int64, Symbol, Float64, Matrix{Symbol}}, Symbol}},typeof(plot!),Plot{GRBackend},Matrix{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot!)),NamedTuple{(:line, :seriestype), Tuple{Tuple{Int64, Symbol, Float64, Matrix{Symbol}}, Symbol}},typeof(plot!),Plot{PlotlyBackend},Matrix{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot!)),NamedTuple{(:lw, :color), Tuple{Int64, Symbol}},typeof(plot!),Function,Float64,Vararg{Any, N} where N})
    Base.precompile(Tuple{Core.kwftype(typeof(plot!)),NamedTuple{(:lw, :color), Tuple{Int64, Symbol}},typeof(plot!),Plot{GRBackend},Function,Vararg{Any, N} where N})
    Base.precompile(Tuple{Core.kwftype(typeof(plot!)),NamedTuple{(:marker, :series_annotations, :seriestype), Tuple{Tuple{Int64, Float64, Symbol}, Vector{Any}, Symbol}},typeof(plot!),Plot{GRBackend},StepRangeLen{Float64, Base.TwicePrecision{Float64}, Base.TwicePrecision{Float64}},Vararg{Any, N} where N})
    Base.precompile(Tuple{Core.kwftype(typeof(plot!)),NamedTuple{(:marker, :series_annotations, :seriestype), Tuple{Tuple{Int64, Float64, Symbol}, Vector{Any}, Symbol}},typeof(plot!),Plot{PlotlyBackend},StepRangeLen{Float64, Base.TwicePrecision{Float64}, Base.TwicePrecision{Float64}},Vararg{Any, N} where N})
    Base.precompile(Tuple{Core.kwftype(typeof(plot!)),NamedTuple{(:marker, :series_annotations, :seriestype), Tuple{Tuple{Int64, Float64, Symbol}, Vector{Any}, Symbol}},typeof(plot!),StepRangeLen{Float64, Base.TwicePrecision{Float64}, Base.TwicePrecision{Float64}},Vector{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot!)),NamedTuple{(:markersize, :c, :seriestype), Tuple{Int64, Symbol, Symbol}},typeof(plot!),Vector{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot!)),NamedTuple{(:seriestype, :inset), Tuple{Symbol, Tuple{Int64, BoundingBox{Tuple{Length{:w, Float64}, Length{:h, Float64}}, Tuple{Length{:w, Float64}, Length{:h, Float64}}}}}},typeof(plot!),Plot{GRBackend},Vector{Int64},Vararg{Any, N} where N})
    Base.precompile(Tuple{Core.kwftype(typeof(plot!)),NamedTuple{(:seriestype, :inset), Tuple{Symbol, Tuple{Int64, BoundingBox{Tuple{Length{:w, Float64}, Length{:h, Float64}}, Tuple{Length{:w, Float64}, Length{:h, Float64}}}}}},typeof(plot!),Plot{PlotlyBackend},Vector{Int64},Vararg{Any, N} where N})
    Base.precompile(Tuple{Core.kwftype(typeof(plot!)),NamedTuple{(:seriestype, :inset), Tuple{Symbol, Tuple{Int64, BoundingBox{Tuple{Length{:w, Float64}, Length{:h, Float64}}, Tuple{Length{:w, Float64}, Length{:h, Float64}}}}}},typeof(plot!),Vector{Int64},Vector{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot!)),NamedTuple{(:seriestype,), Tuple{Symbol}},typeof(plot!),Vector{Int64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot!)),NamedTuple{(:title,), Tuple{String}},typeof(plot!),Plot{GRBackend}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot!)),NamedTuple{(:title,), Tuple{String}},typeof(plot!)})
    Base.precompile(Tuple{Core.kwftype(typeof(plot!)),NamedTuple{(:w,), Tuple{Int64}},typeof(plot!),Plot{GRBackend},Vector{Float64},Vararg{Any, N} where N})
    Base.precompile(Tuple{Core.kwftype(typeof(plot!)),NamedTuple{(:xgrid,), Tuple{Tuple{Symbol, Symbol, Int64, Symbol, Float64}}},typeof(plot!),Plot{GRBackend}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot!)),NamedTuple{(:yaxis,), Tuple{Tuple{String, Symbol}}},typeof(plot!)})
    Base.precompile(Tuple{Core.kwftype(typeof(plot!)),NamedTuple{(:zcolor, :m, :ms, :lab, :seriestype), Tuple{Vector{Float64}, Tuple{Symbol, Float64, Stroke}, Vector{Float64}, String, Symbol}},typeof(plot!),Plot{GRBackend},Vector{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot!)),NamedTuple{(:zcolor, :m, :ms, :lab, :seriestype), Tuple{Vector{Float64}, Tuple{Symbol, Float64, Stroke}, Vector{Float64}, String, Symbol}},typeof(plot!),Plot{PlotlyBackend},Vector{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot!)),NamedTuple{(:zcolor, :m, :ms, :lab, :seriestype), Tuple{Vector{Float64}, Tuple{Symbol, Float64, Stroke}, Vector{Float64}, String, Symbol}},typeof(plot!),Vector{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:annotations, :leg), Tuple{Tuple{Int64, Float64, PlotText}, Bool}},typeof(plot),Vector{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:aspect_ratio, :seriestype), Tuple{Int64, Symbol}},typeof(plot),Vector{String},Vector{String},Vararg{Any, N} where N})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:bins, :weights, :seriestype), Tuple{Symbol, Vector{Int64}, Symbol}},typeof(plot),Vector{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:color, :line, :marker), Tuple{Matrix{Symbol}, Tuple{Symbol, Int64}, Tuple{Matrix{Symbol}, Int64, Float64, Stroke}}},typeof(plot),Vector{Vector{T} where T}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:connections, :seriestype), Tuple{Tuple{Vector{Int64}, Vector{Int64}, Vector{Int64}}, Symbol}},typeof(plot),Vector{Int64},Vector{Int64},Vararg{Vector{Int64}, N} where N})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:fill, :seriestype), Tuple{Bool, Symbol}},typeof(plot),StepRangeLen{Float64, Base.TwicePrecision{Float64}, Base.TwicePrecision{Float64}},StepRangeLen{Float64, Base.TwicePrecision{Float64}, Base.TwicePrecision{Float64}},Vararg{Any, N} where N})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:framestyle, :title, :color, :layout, :label, :markerstrokewidth, :ticks, :seriestype), Tuple{Matrix{Symbol}, Matrix{String}, Base.ReshapedArray{Int64, 2, UnitRange{Int64}, Tuple{}}, Int64, String, Int64, UnitRange{Int64}, Symbol}},typeof(plot),Vector{Vector{Float64}},Vector{Vector{Float64}}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:grid, :title), Tuple{Tuple{Symbol, Symbol, Symbol, Int64, Float64}, String}},typeof(plot),Vector{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:lab, :w, :palette, :fill, :α), Tuple{String, Int64, PlotUtils.ContinuousColorGradient, Int64, Float64}},typeof(plot),StepRange{Int64, Int64},Matrix{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:label, :title, :xlabel, :linewidth, :legend), Tuple{Matrix{String}, String, String, Int64, Symbol}},typeof(plot),Vector{Function},Float64,Vararg{Float64, N} where N})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:label,), Tuple{Matrix{String}}},typeof(plot),Vector{AbstractVector{Float64}}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:layout, :group, :linetype, :linecolor), Tuple{GridLayout, Vector{String}, Matrix{Symbol}, Symbol}},typeof(plot),Vector{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:layout, :label, :fillrange, :fillalpha), Tuple{Tuple{Int64, Int64}, String, Int64, Float64}},typeof(plot),Plot{GRBackend},Plot{GRBackend},Vararg{Plot{GRBackend}, N} where N})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:layout, :label, :fillrange, :fillalpha), Tuple{Tuple{Int64, Int64}, String, Int64, Float64}},typeof(plot),Plot{PlotlyBackend},Plot{PlotlyBackend},Vararg{Plot{PlotlyBackend}, N} where N})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:layout, :link), Tuple{Int64, Symbol}},typeof(plot),Plot{GRBackend},Plot{GRBackend}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:layout, :link), Tuple{Int64, Symbol}},typeof(plot),Plot{PlotlyBackend},Plot{PlotlyBackend}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:layout, :palette, :bg_inside), Tuple{Int64, Matrix{PlotUtils.ContinuousColorGradient}, Matrix{Symbol}}},typeof(plot),Matrix{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:layout, :t, :leg, :ticks, :border), Tuple{GridLayout, Matrix{Symbol}, Bool, Nothing, Symbol}},typeof(plot),Matrix{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:layout, :title, :titlelocation, :left_margin, :bottom_margin, :xrotation), Tuple{GridLayout, Matrix{String}, Symbol, Matrix{AbsoluteLength}, AbsoluteLength, Int64}},typeof(plot),Matrix{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:layout, :xguide, :yguide, :xguidefonthalign, :yguidefontvalign, :xguideposition, :yguideposition, :ymirror, :xmirror, :legend, :seriestype), Tuple{Int64, String, String, Matrix{Symbol}, Matrix{Symbol}, Symbol, Matrix{Symbol}, Matrix{Bool}, Matrix{Bool}, Bool, Matrix{Symbol}}},typeof(plot),Matrix{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:layout, :xlims), Tuple{GridLayout, Tuple{Int64, Float64}}},typeof(plot),Plot{GRBackend},Plot{GRBackend},Vararg{Plot{GRBackend}, N} where N})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:layout,), Tuple{Tuple{Int64, Int64}}},typeof(plot),Plot{GRBackend},Plot{GRBackend},Vararg{Plot{GRBackend}, N} where N})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:layout,), Tuple{Tuple{Int64, Int64}}},typeof(plot),Plot{PlotlyBackend},Plot{PlotlyBackend},Vararg{Plot{PlotlyBackend}, N} where N})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:legend,), Tuple{Bool}},typeof(plot),Plot{GRBackend},Plot{GRBackend},Vararg{Plot{GRBackend}, N} where N})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:legend,), Tuple{Bool}},typeof(plot),Plot{PlotlyBackend},Plot{PlotlyBackend},Vararg{Plot{PlotlyBackend}, N} where N})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:legend,), Tuple{Symbol}},typeof(plot),Plot{GRBackend},Plot{GRBackend},Vararg{Plot{GRBackend}, N} where N})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:legend,), Tuple{Symbol}},typeof(plot),Plot{PlotlyBackend},Plot{PlotlyBackend},Vararg{Plot{PlotlyBackend}, N} where N})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:legend,), Tuple{Symbol}},typeof(plot),Vector{Tuple{Int64, Real}}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:line, :lab, :ms), Tuple{Tuple{Matrix{Symbol}, Int64}, Matrix{String}, Int64}},typeof(plot),Vector{Vector{T} where T},Matrix{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:line, :label, :legendtitle), Tuple{Tuple{Int64, Matrix{Symbol}}, Matrix{String}, String}},typeof(plot),Matrix{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:line, :leg, :fill), Tuple{Int64, Bool, Tuple{Int64, Symbol}}},typeof(plot),Function,Function,Vararg{Any, N} where N})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:line, :marker, :bg, :fg, :xlim, :ylim, :leg), Tuple{Tuple{Int64, Symbol, Symbol}, Tuple{Shape{Float64, Float64}, Int64, RGBA{Float64}}, Symbol, Symbol, Tuple{Int64, Int64}, Tuple{Int64, Int64}, Bool}},typeof(plot),StepRangeLen{Float64, Base.TwicePrecision{Float64}, Base.TwicePrecision{Float64}},Vector{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:line_z, :linewidth, :legend), Tuple{StepRangeLen{Float64, Base.TwicePrecision{Float64}, Base.TwicePrecision{Float64}}, Int64, Bool}},typeof(plot),Vector{Float64},Vector{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:m, :markersize, :lab, :bg, :xlim, :ylim, :seriestype), Tuple{Matrix{Symbol}, Int64, Matrix{String}, Symbol, Tuple{Int64, Int64}, Tuple{Int64, Int64}, Symbol}},typeof(plot),StepRangeLen{Float64, Base.TwicePrecision{Float64}, Base.TwicePrecision{Float64}},Matrix{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:marker,), Tuple{Bool}},typeof(plot),Vector{Union{Missing, Int64}}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:marker_z, :color, :legend, :seriestype), Tuple{typeof(+), Symbol, Bool, Symbol}},typeof(plot),Vector{Float64},Vector{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:markershape, :markersize, :marker_z, :line_z, :linewidth), Tuple{Matrix{Symbol}, Matrix{Int64}, Matrix{Int64}, Matrix{Int64}, Matrix{Int64}}},typeof(plot),Matrix{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:markershape, :seriestype, :label), Tuple{Symbol, Symbol, String}},typeof(plot),UnitRange{Int64},Vector{Int64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:nbins, :seriestype), Tuple{Int64, Symbol}},typeof(plot),Vector{Float64},Vector{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:nbins, :show_empty_bins, :normed, :aspect_ratio, :seriestype), Tuple{Tuple{Int64, Int64}, Bool, Bool, Int64, Symbol}},typeof(plot),Vector{ComplexF64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:proj, :m), Tuple{Symbol, Int64}},typeof(plot),StepRangeLen{Float64, Base.TwicePrecision{Float64}, Base.TwicePrecision{Float64}},Vector{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:projection, :seriestype), Tuple{Symbol, Symbol}},typeof(plot),StepRangeLen{Float64, Base.TwicePrecision{Float64}, Base.TwicePrecision{Float64}},UnitRange{Int64},Vararg{Any, N} where N})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:quiver, :seriestype), Tuple{Tuple{Vector{Float64}, Vector{Float64}, Vector{Float64}}, Symbol}},typeof(plot),Vector{Float64},Vector{Float64},Vararg{Vector{Float64}, N} where N})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:reg, :fill), Tuple{Bool, Tuple{Int64, Symbol}}},typeof(plot),Vector{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:ribbon,), Tuple{Tuple{LinRange{Float64}, LinRange{Float64}}}},typeof(plot),UnitRange{Int64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:ribbon,), Tuple{typeof(sqrt)}},typeof(plot),UnitRange{Int64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:seriestype, :markershape, :markersize, :color), Tuple{Matrix{Symbol}, Vector{Symbol}, Int64, Vector{Symbol}}},typeof(plot),Matrix{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:seriestype,), Tuple{Symbol}},typeof(plot),Vector{DateTime},UnitRange{Int64},Vararg{Any, N} where N})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:seriestype,), Tuple{Symbol}},typeof(plot),Vector{OHLC}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:st, :xlabel, :ylabel, :zlabel), Tuple{Symbol, String, String, String}},typeof(plot),Vector{Float64},Vector{Float64},Vararg{Vector{Float64}, N} where N})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:title, :l, :seriestype), Tuple{String, Float64, Symbol}},typeof(plot),Vector{String},Vector{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:title,), Tuple{Matrix{String}}},typeof(plot),Plot{GRBackend},Plot{GRBackend}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:title,), Tuple{Matrix{String}}},typeof(plot),Plot{PlotlyBackend},Plot{PlotlyBackend}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:title,), Tuple{String}},typeof(plot),Plot{GRBackend}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:title,), Tuple{String}},typeof(plot),Plot{PlotlyBackend}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:w,), Tuple{Int64}},typeof(plot),Matrix{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:xaxis, :background_color, :leg), Tuple{Tuple{String, Tuple{Int64, Int64}, StepRange{Int64, Int64}, Symbol}, RGB{Float64}, Bool}},typeof(plot),Matrix{Float64}})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:yflip, :aspect_ratio), Tuple{Bool, Symbol}},typeof(plot),Vector{Float64},Vector{Int64},Vararg{Any, N} where N})
    Base.precompile(Tuple{Core.kwftype(typeof(plot)),NamedTuple{(:zcolor, :m, :leg, :cbar, :w), Tuple{StepRange{Int64, Int64}, Tuple{Int64, Float64, Symbol, Stroke}, Bool, Bool, Int64}},typeof(plot),Vector{Float64},Vector{Float64},Vararg{Any, N} where N})
    Base.precompile(Tuple{Core.kwftype(typeof(portfoliocomposition)),Any,typeof(portfoliocomposition),Any,Vararg{Any, N} where N})
    Base.precompile(Tuple{Core.kwftype(typeof(scatter!)),Any,typeof(scatter!),Any,Vararg{Any, N} where N})
    Base.precompile(Tuple{Core.kwftype(typeof(scatter!)),Any,typeof(scatter!),Any})
    Base.precompile(Tuple{Core.kwftype(typeof(test_examples)),NamedTuple{(:skip,), Tuple{Vector{Int64}}},typeof(test_examples),Symbol})
    Base.precompile(Tuple{Type{GridLayout},Int64,Vararg{Int64, N} where N})
    Base.precompile(Tuple{typeof(RecipesBase.apply_recipe),AbstractDict{Symbol, Any},AbstractVector{OHLC}})
    Base.precompile(Tuple{typeof(RecipesBase.apply_recipe),AbstractDict{Symbol, Any},PortfolioComposition})
    Base.precompile(Tuple{typeof(RecipesBase.apply_recipe),AbstractDict{Symbol, Any},Type{Val{:barhist}},Any,Any,Any})
    Base.precompile(Tuple{typeof(RecipesBase.apply_recipe),AbstractDict{Symbol, Any},Type{Val{:bar}},Any,Any,Any})
    Base.precompile(Tuple{typeof(RecipesBase.apply_recipe),AbstractDict{Symbol, Any},Type{Val{:bins2d}},Any,Any,Any})
    Base.precompile(Tuple{typeof(RecipesBase.apply_recipe),AbstractDict{Symbol, Any},Type{Val{:histogram2d}},Any,Any,Any})
    Base.precompile(Tuple{typeof(RecipesBase.apply_recipe),AbstractDict{Symbol, Any},Type{Val{:hline}},Any,Any,Any})
    Base.precompile(Tuple{typeof(RecipesBase.apply_recipe),AbstractDict{Symbol, Any},Type{Val{:lens}},AbstractPlot})
    Base.precompile(Tuple{typeof(RecipesBase.apply_recipe),AbstractDict{Symbol, Any},Type{Val{:pie}},Any,Any,Any})
    Base.precompile(Tuple{typeof(RecipesBase.apply_recipe),AbstractDict{Symbol, Any},Type{Val{:quiver}},Any,Any,Any})
    Base.precompile(Tuple{typeof(RecipesBase.apply_recipe),AbstractDict{Symbol, Any},Type{Val{:steppre}},Any,Any,Any})
    Base.precompile(Tuple{typeof(RecipesBase.apply_recipe),AbstractDict{Symbol, Any},Type{Val{:sticks}},Any,Any,Any})
    Base.precompile(Tuple{typeof(RecipesBase.apply_recipe),AbstractDict{Symbol, Any},Type{Val{:vline}},Any,Any,Any})
    Base.precompile(Tuple{typeof(RecipesBase.apply_recipe),AbstractDict{Symbol, Any},Type{Val{:xerror}},Any,Any,Any})
    Base.precompile(Tuple{typeof(RecipesBase.apply_recipe),AbstractDict{Symbol, Any},Vector{ComplexF64}})
    Base.precompile(Tuple{typeof(RecipesPipeline.add_series!),Plot{GRBackend},DefaultsDict})
    Base.precompile(Tuple{typeof(RecipesPipeline.add_series!),Plot{PlotlyBackend},DefaultsDict})
    Base.precompile(Tuple{typeof(RecipesPipeline.plot_setup!),Plot{GRBackend},Dict{Symbol, Any},Vector{Dict{Symbol, Any}}})
    Base.precompile(Tuple{typeof(RecipesPipeline.plot_setup!),Plot{PlotlyBackend},Dict{Symbol, Any},Vector{Dict{Symbol, Any}}})
    Base.precompile(Tuple{typeof(RecipesPipeline.preprocess_attributes!),Plot{GRBackend},DefaultsDict})
    Base.precompile(Tuple{typeof(RecipesPipeline.process_userrecipe!),Plot{GRBackend},Vector{Dict{Symbol, Any}},Dict{Symbol, Any}})
    Base.precompile(Tuple{typeof(RecipesPipeline.process_userrecipe!),Plot{PlotlyBackend},Vector{Dict{Symbol, Any}},Dict{Symbol, Any}})
    Base.precompile(Tuple{typeof(RecipesPipeline.warn_on_recipe_aliases!),Plot{GRBackend},DefaultsDict,Symbol,Any})
    Base.precompile(Tuple{typeof(RecipesPipeline.warn_on_recipe_aliases!),Plot{GRBackend},Dict{Symbol, Any},Symbol,Any})
    Base.precompile(Tuple{typeof(RecipesPipeline.warn_on_recipe_aliases!),Plot{PlotlyBackend},DefaultsDict,Symbol,Any})
    Base.precompile(Tuple{typeof(RecipesPipeline.warn_on_recipe_aliases!),Plot{PlotlyBackend},Dict{Symbol, Any},Symbol,Any})
    Base.precompile(Tuple{typeof(_bin_centers),StepRangeLen{Float64, Base.TwicePrecision{Float64}, Base.TwicePrecision{Float64}}})
    Base.precompile(Tuple{typeof(_cbar_unique),Vector{Int64},String})
    Base.precompile(Tuple{typeof(_cbar_unique),Vector{Nothing},String})
    Base.precompile(Tuple{typeof(_cbar_unique),Vector{PlotUtils.ContinuousColorGradient},String})
    Base.precompile(Tuple{typeof(_cbar_unique),Vector{StepRangeLen{Float64, Base.TwicePrecision{Float64}, Base.TwicePrecision{Float64}}},String})
    Base.precompile(Tuple{typeof(_cbar_unique),Vector{Symbol},String})
    Base.precompile(Tuple{typeof(_do_plot_show),Plot{GRBackend},Bool})
    Base.precompile(Tuple{typeof(_heatmap_edges),Vector{Float64},Bool,Bool})
    Base.precompile(Tuple{typeof(_plot!),Plot,Any,Any})
    Base.precompile(Tuple{typeof(_preprocess_barlike),DefaultsDict,Base.OneTo{Int64},Vector{Float64}})
    Base.precompile(Tuple{typeof(_preprocess_binlike),DefaultsDict,StepRangeLen{Float64, Base.TwicePrecision{Float64}, Base.TwicePrecision{Float64}},Vector{Float64}})
    Base.precompile(Tuple{typeof(_update_min_padding!),GridLayout})
    Base.precompile(Tuple{typeof(_update_subplot_args),Plot{GRBackend},Subplot{GRBackend},Dict{Symbol, Any},Int64,Bool})
    Base.precompile(Tuple{typeof(_update_subplot_args),Plot{PlotlyBackend},Subplot{PlotlyBackend},Dict{Symbol, Any},Int64,Bool})
    Base.precompile(Tuple{typeof(_update_subplot_periphery),Subplot{GRBackend},Vector{Any}})
    Base.precompile(Tuple{typeof(_update_subplot_periphery),Subplot{PlotlyBackend},Vector{Any}})
    Base.precompile(Tuple{typeof(backend),PlotlyBackend})
    Base.precompile(Tuple{typeof(bbox),AbsoluteLength,AbsoluteLength,AbsoluteLength,AbsoluteLength})
    Base.precompile(Tuple{typeof(bbox),Float64,Float64,Float64,Float64})
    Base.precompile(Tuple{typeof(build_layout),GridLayout,Int64})
    Base.precompile(Tuple{typeof(contour),Any,Vararg{Any, N} where N})
    Base.precompile(Tuple{typeof(convert_to_polar),StepRangeLen{Float64, Base.TwicePrecision{Float64}, Base.TwicePrecision{Float64}},Vector{Float64},Tuple{Int64, Float64}})
    Base.precompile(Tuple{typeof(create_grid),Expr})
    Base.precompile(Tuple{typeof(error_coords),Vector{Float64},Vector{Float64},Vector{Float64},Vararg{Vector{Float64}, N} where N})
    Base.precompile(Tuple{typeof(error_coords),Vector{Float64},Vector{Float64},Vector{Float64}})
    Base.precompile(Tuple{typeof(error_zipit),Tuple{Vector{Float64}, Vector{Float64}, Vector{Float64}}})
    Base.precompile(Tuple{typeof(font),String,Vararg{Any, N} where N})
    Base.precompile(Tuple{typeof(get_minor_ticks),Subplot{GRBackend},Axis,Tuple{Vector{Float64}, Vector{String}}})
    Base.precompile(Tuple{typeof(get_minor_ticks),Subplot{GRBackend},Axis,Tuple{Vector{Int64}, Vector{String}}})
    Base.precompile(Tuple{typeof(get_ticks),StepRange{Int64, Int64},Vector{Float64},Vector{Any},Tuple{Int64, Int64},Vararg{Any, N} where N})
    Base.precompile(Tuple{typeof(get_ticks),Symbol,Vector{Float64},Vector{Any},Tuple{Float64, Float64},Vararg{Any, N} where N})
    Base.precompile(Tuple{typeof(get_ticks),Symbol,Vector{Float64},Vector{Any},Tuple{Int64, Float64},Vararg{Any, N} where N})
    Base.precompile(Tuple{typeof(get_ticks),Symbol,Vector{Float64},Vector{Any},Tuple{Int64, Int64},Vararg{Any, N} where N})
    Base.precompile(Tuple{typeof(get_ticks),UnitRange{Int64},Vector{Float64},Vector{Any},Tuple{Float64, Float64},Vararg{Any, N} where N})
    Base.precompile(Tuple{typeof(get_xy),Vector{OHLC}})
    Base.precompile(Tuple{typeof(gr_add_legend),Subplot{GRBackend},NamedTuple{(:w, :h, :dy, :leftw, :textw, :rightw, :xoffset, :yoffset, :width_factor), NTuple{9, Float64}},Vector{Float64}})
    Base.precompile(Tuple{typeof(gr_add_legend),Subplot{GRBackend},NamedTuple{(:w, :h, :dy, :leftw, :textw, :rightw, :xoffset, :yoffset, :width_factor), Tuple{Int64, Float64, Float64, Float64, Int64, Float64, Float64, Float64, Float64}},Vector{Float64}})
    Base.precompile(Tuple{typeof(gr_display),Subplot{GRBackend},AbsoluteLength,AbsoluteLength,Vector{Float64}})
    Base.precompile(Tuple{typeof(gr_draw_colorbar),GRColorbar,Subplot{GRBackend},Tuple{Float64, Float64},Vector{Float64}})
    Base.precompile(Tuple{typeof(gr_draw_contour),Series,StepRangeLen{Float64, Base.TwicePrecision{Float64}, Base.TwicePrecision{Float64}},StepRangeLen{Float64, Base.TwicePrecision{Float64}, Base.TwicePrecision{Float64}},Matrix{Float64},Tuple{Float64, Float64}})
    Base.precompile(Tuple{typeof(gr_draw_heatmap),Series,Vector{Float64},Vector{Float64},Matrix{Float64},Tuple{Float64, Float64}})
    Base.precompile(Tuple{typeof(gr_draw_marker),Series,Float64,Float64,Tuple{Float64, Float64},Int64,Int64,Int64,Shape{Float64, Float64}})
    Base.precompile(Tuple{typeof(gr_draw_segments),Series,Base.OneTo{Int64},UnitRange{Int64},Tuple{Vector{Float64}, Vector{Float64}},Tuple{Float64, Float64}})
    Base.precompile(Tuple{typeof(gr_draw_segments),Series,Base.OneTo{Int64},Vector{Float64},Int64,Tuple{Float64, Float64}})
    Base.precompile(Tuple{typeof(gr_draw_segments),Series,StepRange{Int64, Int64},Vector{Float64},Int64,Tuple{Float64, Float64}})
    Base.precompile(Tuple{typeof(gr_draw_segments),Series,Vector{Float64},Vector{Float64},Int64,Tuple{Float64, Float64}})
    Base.precompile(Tuple{typeof(gr_draw_shapes),Series,Tuple{Float64, Float64}})
    Base.precompile(Tuple{typeof(gr_draw_surface),Series,Vector{Float64},Vector{Float64},Matrix{Float64},Tuple{Float64, Float64}})
    Base.precompile(Tuple{typeof(gr_draw_surface),Series,Vector{Float64},Vector{Float64},Vector{Float64},Tuple{Float64, Float64}})
    Base.precompile(Tuple{typeof(gr_get_ticks_size),Tuple{Vector{Float64}, Vector{String}},Int64})
    Base.precompile(Tuple{typeof(gr_label_ticks),Subplot{GRBackend},Symbol,Tuple{Vector{Float64}, Vector{String}}})
    Base.precompile(Tuple{typeof(gr_label_ticks_3d),Subplot{GRBackend},Symbol,Tuple{Vector{Float64}, Vector{String}}})
    Base.precompile(Tuple{typeof(gr_polaraxes),Int64,Float64,Subplot{GRBackend}})
    Base.precompile(Tuple{typeof(gr_set_gradient),PlotUtils.ContinuousColorGradient})
    Base.precompile(Tuple{typeof(gr_update_viewport_legend!),Vector{Float64},Subplot{GRBackend},NamedTuple{(:w, :h, :dy, :leftw, :textw, :rightw, :xoffset, :yoffset, :width_factor), NTuple{9, Float64}}})
    Base.precompile(Tuple{typeof(gr_update_viewport_legend!),Vector{Float64},Subplot{GRBackend},NamedTuple{(:w, :h, :dy, :leftw, :textw, :rightw, :xoffset, :yoffset, :width_factor), Tuple{Int64, Float64, Float64, Float64, Int64, Float64, Float64, Float64, Float64}}})
    Base.precompile(Tuple{typeof(gr_viewport_from_bbox),Subplot{GRBackend},BoundingBox{Tuple{AbsoluteLength, AbsoluteLength}, Tuple{AbsoluteLength, AbsoluteLength}},AbsoluteLength,AbsoluteLength,Vector{Float64}})
    Base.precompile(Tuple{typeof(heatmap_edges),Base.OneTo{Int64},Symbol})
    Base.precompile(Tuple{typeof(heatmap_edges),StepRangeLen{Float64, Base.TwicePrecision{Float64}, Base.TwicePrecision{Float64}},Symbol,StepRangeLen{Float64, Base.TwicePrecision{Float64}, Base.TwicePrecision{Float64}},Symbol,Tuple{Int64, Int64},Bool})
    Base.precompile(Tuple{typeof(heatmap_edges),StepRangeLen{Float64, Base.TwicePrecision{Float64}, Base.TwicePrecision{Float64}},Symbol})
    Base.precompile(Tuple{typeof(heatmap_edges),UnitRange{Int64},Symbol})
    Base.precompile(Tuple{typeof(heatmap_edges),Vector{Float64},Symbol,UnitRange{Int64},Symbol,Tuple{Int64, Int64},Bool})
    Base.precompile(Tuple{typeof(heatmap_edges),Vector{Float64},Symbol,Vector{Float64},Symbol,Tuple{Int64, Int64},Bool})
    Base.precompile(Tuple{typeof(heatmap_edges),Vector{Float64},Symbol})
    Base.precompile(Tuple{typeof(ignorenan_minimum),Vector{Int64}})
    Base.precompile(Tuple{typeof(layout_args),Int64})
    Base.precompile(Tuple{typeof(make_fillrange_side),UnitRange{Int64},StepRangeLen{Float64, Base.TwicePrecision{Float64}, Base.TwicePrecision{Float64}}})
    Base.precompile(Tuple{typeof(optimal_ticks_and_labels),Nothing,Tuple{Float64, Float64},Symbol,Function})
    Base.precompile(Tuple{typeof(optimal_ticks_and_labels),Nothing,Tuple{Float64, Float64},Symbol,Symbol})
    Base.precompile(Tuple{typeof(optimal_ticks_and_labels),Nothing,Tuple{Int64, Float64},Symbol,Symbol})
    Base.precompile(Tuple{typeof(optimal_ticks_and_labels),Nothing,Tuple{Int64, Int64},Symbol,Symbol})
    Base.precompile(Tuple{typeof(optimal_ticks_and_labels),StepRange{Int64, Int64},Tuple{Int64, Int64},Symbol,Symbol})
    Base.precompile(Tuple{typeof(optimal_ticks_and_labels),UnitRange{Int64},Tuple{Float64, Float64},Symbol,Symbol})
    Base.precompile(Tuple{typeof(partialcircle),Int64,Float64,Int64})
    Base.precompile(Tuple{typeof(plot),Any,Any,Vararg{Any, N} where N})
    Base.precompile(Tuple{typeof(plot),Any})
    Base.precompile(Tuple{typeof(processGridArg!),Dict{Symbol, Any},Symbol,Symbol})
    Base.precompile(Tuple{typeof(processLineArg),Dict{Symbol, Any},Matrix{Symbol}})
    Base.precompile(Tuple{typeof(processLineArg),Dict{Symbol, Any},Symbol})
    Base.precompile(Tuple{typeof(processMarkerArg),Dict{Symbol, Any},Matrix{Symbol}})
    Base.precompile(Tuple{typeof(processMarkerArg),Dict{Symbol, Any},RGBA{Float64}})
    Base.precompile(Tuple{typeof(processMarkerArg),Dict{Symbol, Any},Shape{Float64, Float64}})
    Base.precompile(Tuple{typeof(processMarkerArg),Dict{Symbol, Any},Symbol})
    Base.precompile(Tuple{typeof(process_annotation),Subplot{GRBackend},Int64,Float64,PlotText})
    Base.precompile(Tuple{typeof(process_annotation),Subplot{PlotlyBackend},Int64,Float64,PlotText})
    Base.precompile(Tuple{typeof(process_axis_arg!),Dict{Symbol, Any},StepRange{Int64, Int64},Symbol})
    Base.precompile(Tuple{typeof(process_axis_arg!),Dict{Symbol, Any},Symbol,Symbol})
    Base.precompile(Tuple{typeof(push!),Plot{GRBackend},Float64,Vector{Float64}})
    Base.precompile(Tuple{typeof(slice_arg),Base.ReshapedArray{Int64, 2, UnitRange{Int64}, Tuple{}},Int64})
    Base.precompile(Tuple{typeof(spy),Any})
    Base.precompile(Tuple{typeof(straightline_data),Tuple{Float64, Float64},Tuple{Float64, Float64},Vector{Float64},Vector{Float64},Int64})
    Base.precompile(Tuple{typeof(stroke),Int64,Vararg{Any, N} where N})
    Base.precompile(Tuple{typeof(text),String,Int64,Symbol,Vararg{Symbol, N} where N})
    Base.precompile(Tuple{typeof(text),String,Symbol,Int64,Vararg{Any, N} where N})
    Base.precompile(Tuple{typeof(title!),AbstractString})
    Base.precompile(Tuple{typeof(unzip),Vector{GeometryBasics.Point2{Float64}}})
    Base.precompile(Tuple{typeof(vline!),Any})
    Base.precompile(Tuple{typeof(xgrid!),Plot{GRBackend},Symbol,Vararg{Any, N} where N})
    Base.precompile(Tuple{typeof(xlims),Subplot{PlotlyBackend}})
    Base.precompile(Tuple{typeof(yaxis!),Any,Any})
    isdefined(Plots, Symbol("#162#163")) && Base.precompile(Tuple{getfield(Plots, Symbol("#162#163")),Tuple{Int64, Symbol}})
    let fbody = try __lookup_kwbody__(which(plot!, (Any,))) catch missing end
        if !ismissing(fbody)
            precompile(fbody, (Any,typeof(plot!),Any,))
        end
    end
    let fbody = try __lookup_kwbody__(which(plot!, (Any,Vararg{Any, N} where N,))) catch missing end
        if !ismissing(fbody)
            precompile(fbody, (Any,typeof(plot!),Any,Vararg{Any, N} where N,))
        end
    end
    let fbody = try __lookup_kwbody__(which(plot, (Any,))) catch missing end
        if !ismissing(fbody)
            precompile(fbody, (Any,typeof(plot),Any,))
        end
    end
    let fbody = try __lookup_kwbody__(which(plot, (Any,Vararg{Any, N} where N,))) catch missing end
        if !ismissing(fbody)
            precompile(fbody, (Any,typeof(plot),Any,Vararg{Any, N} where N,))
        end
    end
    let fbody = try __lookup_kwbody__(which(plot, (Plot,Plot,Vararg{Plot, N} where N,))) catch missing end
        if !ismissing(fbody)
            precompile(fbody, (Any,typeof(plot),Plot,Plot,Vararg{Plot, N} where N,))
        end
    end
    let fbody = try __lookup_kwbody__(which(text, (String,Int64,Vararg{Any, N} where N,))) catch missing end
        if !ismissing(fbody)
            precompile(fbody, (Base.Iterators.Pairs{Union{}, Union{}, Tuple{}, NamedTuple{(), Tuple{}}},typeof(text),String,Int64,Vararg{Any, N} where N,))
        end
    end
    let fbody = try __lookup_kwbody__(which(text, (String,Symbol,Vararg{Any, N} where N,))) catch missing end
        if !ismissing(fbody)
            precompile(fbody, (Base.Iterators.Pairs{Union{}, Union{}, Tuple{}, NamedTuple{(), Tuple{}}},typeof(text),String,Symbol,Vararg{Any, N} where N,))
        end
    end
    let fbody = try __lookup_kwbody__(which(title!, (AbstractString,))) catch missing end
        if !ismissing(fbody)
            precompile(fbody, (Any,typeof(title!),AbstractString,))
        end
    end
end
