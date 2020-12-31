# frozen_string_literal: true

dataset = [
  { customer: 'Уфа, улица  Абаканская 16', address: 'Федотова Д. М.' },
  { customer: 'Уфа, улица  Ажурная 3', address: 'Ежова Э. К.' },
  { customer: 'Уфа, улица  Академика Филатова 23', address: 'Лаврентьева М. М.' },
  { customer: 'Уфа, улица  Генеральская 35', address: 'Макеева В. Р.' },
  { customer: 'Уфа, улица  Георгия Мушникова 32', address: 'Рыжов А. А.' },
]

dataset.each { |set| Order.find_or_create_by(set) }
