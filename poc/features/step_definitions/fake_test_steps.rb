Then /^1 \+ 1 == 2$/ do
  1 + 1 == 2
end

Then /cpu intensive operation/ do
  t1 = Time.now

  rep = 10000
  n   = 10000

  x = Array.new(n, 0)

  for j in 1..rep
    for i in 0..(n-1)
      x[i] += i
    end
  end
end

Then /io intensive operation/ do
  ArProfile.destroy_all
  1000.times do
    ArProfile.create!
  end
end
