using Gen
using GLMakie


# lets create a world of people based on a chinese restaurant process. the world of people will be different
# based on the concentration parameter alpha in the dichlet process. 


@gen function draw_personality_type()
    personality_type = { :ptype } ~ categorical([.2, .6, .2])
    yell = { * } ~ generate_behavior_discrete(personality_type)
    return yell
end


@gen function generate_behavior_discrete(ptype::Int)
    if ptype == 1
        yell_level = { :ylev } ~ categorical([.5, .15, .15, .05, .05, .025, .025, .025, 0.025])
    elseif ptype == 2
        yell_level = { :ylev } ~ categorical([.025, .025, .05, .15, .5, .15, .05, .025, .025])
    elseif ptype == 3
        yell_level = { :ylev } ~  categorical([.025, .025, .025, .025, .05, .05, .15, .15, .5])
    end
end

@dist function labeled_cat(labels, probs)
    index = categorical(probs)
    labels[index]
end


function niche_rejection_sampler(obs_ylev::Int, num_samples::Int)
    i = 0
    inference_results = []
    while  i < num_samples
        tr = simulate(draw_personality_type, ())
        ch = get_choices(tr)
        yell_level = ch[:ylev]
        if yell_level == obs_ylev
            push!(inference_results, ch[:ptype])
            i += 1
            println(i)
        end
    end
    fig = Figure(resolution=(1000, 1000))
    ax = Axis(fig[1, 1])
    hist!(ax, inference_results, xticks=1:1:3, xlabel="Personality Type")
    display(fig)
    return inference_results
end


function enumerate_niche(ptype_possibilities, yell_levels)
    p_grid = zeros(length(ptype_possibilities), length(yell_levels))
    for ptype in ptype_possibilities
        for ylev in yell_levels
            cmap = choicemap((:ptype, ptype), (:ylev, ylev))
            tr, w = generate(draw_personality_type, (), cmap)
            p_grid[ptype, ylev] = exp(w)
            println(w)
        end
    end
    return p_grid
end

function condition(model, args, constraints)
    tr, w = generate(model, args, constraints)
    cp = get_score(tr) - w
    return tr, cp, w
end

            
    
# (trace, lml_est) = importance_resampling(model::GenerativeFunction,
#     model_args::Tuple, observations::ChoiceMap, num_samples::Int,
#     verbose=false)

# (traces, lml_est) = importance_resampling(model::GenerativeFunction,
#     model_args::Tuple, observations::ChoiceMap,
#     proposal::GenerativeFunction, proposal_args::Tuple,
#                                           num_samples::Int, verbose=false)

#function niche_importance_resample(obs_ylev::Int)
    

@gen function draw_animals(animal::String)
    num_legs = { :num_legs } ~ categorical([.001, .001, .005, .99, .003])
    has_tail = { :has_tail } ~ bernoulli(.9)
    is_clifford = { :is_clifford } ~ bernoulli(.1)
    if !is_clifford 
        color = { :color } ~ labeled_cat(["yellow", "black", "white", "brown", "red"],
                                         [.2, .3, .3, .19, .01])
    else
        color = { :color } ~ labeled_cat(["yellow", "black", "white", "brown", "red"],
                                         [.01, .01, .01, .01, .96])
    end
end


# Write out what is happening here in terms of trace generation and the score. What is special about the trace?
# What is w? Describe this specifically in the context of the value your constraint takes on with respect to other variables.
# Find which variable will change w scores if you constrain on the same value for the same variable. 

cmap = choicemap((:num_legs, 3))
tr, w = Gen.generate(draw_animals, ("dog",), cmap)
get_choices(tr)

# Add the new function "condition" here, understand what it is doing, and run the dog model within it. What is different about the score returned from
# condition vs the score returned from generate? Why might this be important in the context of proposals and models? 




# @gen function generate_behavior_continuous(ptype::Int)
#     if ptype == 1
#         yell_level = { :ylev } ~ beta(1, 5)
#     elseif ptype == 2
#         yell_level = { :ylev } ~ beta(2, 2)
#     elseif ptype == 3
#         yell_level = { :ylev } ~ beta(5, 1)
#     end
# end
