module OrdinaryDiffEqExtrapolation

import OrdinaryDiffEq: alg_order, alg_maximum_order, get_current_adaptive_order,
                       get_current_alg_order, calculate_residuals!, accept_step_controller,
                       default_controller, beta2_default, beta1_default, gamma_default,
                       initialize!, perform_step!, @unpack, unwrap_alg, isthreaded,
                       step_accept_controller!, calculate_residuals,
                       OrdinaryDiffEqMutableCache, OrdinaryDiffEqConstantCache,
                       reset_alg_dependent_opts!, AbstractController,
                       step_accept_controller!, step_reject_controller!,
                       OrdinaryDiffEqAdaptiveAlgorithm, OrdinaryDiffEqAdaptiveImplicitAlgorithm,
                       alg_cache, CompiledFloats, @threaded, stepsize_controller!, DEFAULT_PRECS,
                       constvalue, PolyesterThreads, Sequential, BaseThreads,
                       _digest_beta1_beta2, timedepentdtmin, _unwrap_val,
                       TimeDerivativeWrapper, UDerivativeWrapper, calc_J, _reshape, _vec,
                       WOperator, TimeGradientWrapper, UJacobianWrapper, build_grad_config,
                       build_jac_config, calc_J!, jacobian2W!, dolinsolve
using DiffEqBase, FastBroadcast, Polyester, MuladdMacro, RecursiveArrayTools, LinearSolve

macro cache(expr)
    name = expr.args[2].args[1].args[1]
    fields = [x for x in expr.args[3].args if typeof(x) != LineNumberNode]
    cache_vars = Expr[]
    jac_vars = Pair{Symbol, Expr}[]
    for x in fields
        if x.args[2] == :uType || x.args[2] == :rateType ||
           x.args[2] == :kType || x.args[2] == :uNoUnitsType
            push!(cache_vars, :(c.$(x.args[1])))
        elseif x.args[2] == :DiffCacheType
            push!(cache_vars, :(c.$(x.args[1]).du))
            push!(cache_vars, :(c.$(x.args[1]).dual_du))
        end
    end
    quote
        $(esc(expr))
        $(esc(:full_cache))(c::$name) = tuple($(cache_vars...))
    end
end

include("algorithms.jl")
include("alg_utils.jl")
include("controllers.jl")
include("extrapolation_caches.jl")
include("extrapolation_perform_step.jl")

@inline function DiffEqBase.get_tmp_cache(integrator,
        alg::OrdinaryDiffEqImplicitExtrapolationAlgorithm,
        cache::OrdinaryDiffEqMutableCache)
    (cache.tmp, cache.utilde)
end

export AitkenNeville, ExtrapolationMidpointDeuflhard, ExtrapolationMidpointHairerWanner,
       ImplicitEulerExtrapolation,
       ImplicitDeuflhardExtrapolation, ImplicitHairerWannerExtrapolation,
       ImplicitEulerBarycentricExtrapolation

end
