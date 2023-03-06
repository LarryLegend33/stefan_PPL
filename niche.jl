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
            
    
    


        




# @gen function generate_behavior_continuous(ptype::Int)
#     if ptype == 1
#         yell_level = { :ylev } ~ beta(1, 5)
#     elseif ptype == 2
#         yell_level = { :ylev } ~ beta(2, 2)
#     elseif ptype == 3
#         yell_level = { :ylev } ~ beta(5, 1)
#     end
# end
